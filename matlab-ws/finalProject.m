disp('===== LOADING PARAMETERS =====')
tic;
load('cam_all_params.mat');
load('stereoParams_all.mat');
camParams = cell(6,1);
camParams{1} = cameraParams_0;
camParams{2} = cameraParams_1;
camParams{3} = cameraParams_2;
camParams{4} = cameraParams_3;
camParams{5} = cameraParams_4;
camParams{6} = cameraParams_5;
ProjectionMatrix;
toc;
%%
disp('===== OUTPUT FILE CREATING =====')
tic;
fileID = fopen('output.csv', 'w');
fprintf(fileID,'x,y,z\n');
toc;
%%
stats = cell(6,1);
pt = zeros(6,2);  
pt3d = zeros(6,3);
distanceInMeters = zeros(6,1);
trajectoryPoints = cell(6, 1);
%%
disp('===== READING VIDEOS =====')
tic;
videos = cell(1,6);
for i = 1:6
    videos{i} = VideoReader(['cam' num2str(i-1) '.mp4']);
end
toc;
%%
disp('===== GENERATING FIGURES =====')
figure('Units','normalized','Position',[0 0 1 1]);  
t = tiledlayout(2,3,'TileSpacing','none','Padding','none');

for i = 1:6
    nexttile;
    hImgs(i) = imshow(readFrame(videos{i}));
    title(['\fontsize{25}Cam ' num2str(i-1)]);
end
%%
tic;
while all(cellfun(@hasFrame, videos))
    frames = cell(6,1);
    for i = 1:6
        frames{i} = readFrame(videos{i});
    end
    for i = 1:6
        frame = undistortImage(frames{i}, camParams{i});
        [BW, ~] = createMask(frame);
        [labeled, ~] = bwlabel(BW);
        stats{i} = regionprops(labeled, 'Centroid', 'BoundingBox');

        if length(stats{i}) >= 1
            pt(i, :) = stats{i}(1).Centroid;
        end

        if pt(i,:) ~= [0, 0]
            if isempty(trajectoryPoints{i})
                trajectoryPoints{i}(1, :) = pt(i, :);
            else
                trajectoryPoints{i}(end+1, :) = pt(i, :);
            end
        end


        if i == 2
            if ~any(isnan(pt(1, :))) && ~any(isnan(pt(2, :)))
                pt3d(1, :) = triangulateLinear(pt(1,:), pt(2,:), P{1}, P{2});
            else
                pt3d(1, :) = [NaN, NaN, NaN];
            end

        elseif i == 3
            if ~any(isnan(pt(2, :))) && ~any(isnan(pt(3, :)))
                pt3d(2, :) = triangulateLinear(pt(2,:), pt(3,:), P{2}, P{3});
            else
                pt3d(2, :) = [NaN, NaN, NaN];
            end

        elseif i == 4
            if ~any(isnan(pt(3, :))) && ~any(isnan(pt(4, :)))
                pt3d(3, :) = triangulateLinear(pt(3,:), pt(4,:), P{3}, P{4});
            else
                pt3d(3, :) = [NaN, NaN, NaN];
            end

        elseif i == 5
            if ~any(isnan(pt(4, :))) && ~any(isnan(pt(5, :)))
                pt3d(4, :) = triangulateLinear(pt(4,:), pt(5,:), P{4}, P{5});
            else
                pt3d(4, :) = [NaN, NaN, NaN];
            end

        elseif i == 6
            if ~any(isnan(pt(5, :))) && ~any(isnan(pt(6, :)))
                pt3d(5, :) = triangulateLinear(pt(5,:), pt(6,:), P{5}, P{6});
            else
                pt3d(5, :) = [NaN, NaN, NaN];
            end

            if ~any(isnan(pt(6, :))) && ~any(isnan(pt(1, :)))
                pt3d(6, :) = triangulateLinear(pt(6,:), pt(1,:), P{6}, P{1});
            else
                pt3d(6, :) = [NaN, NaN, NaN];
            end
        end
    end

    coordinate = mean(pt3d, 1, 'omitnan');
    fprintf(fileID, '%.2f,%.2f,%.2f\n', coordinate(1,1), coordinate(1,2), coordinate(1,3));
    distanceInMeters = sqrt(sum(coordinate.^2, 'omitnan'));
    annStr = sprintf('X: %.2f\nY: %.2f\nZ: %.2f\nDist: %.2f m', ...
                      coordinate(1,1), coordinate(1,2), coordinate(1,3), distanceInMeters);

    for i = 1:6
        frame = frames{i};
        frame = insertText(frame, [20 20], annStr, 'FontSize', 45, 'BoxColor', 'white', 'BoxOpacity', 0.5);
        points = trajectoryPoints{i};
            if size(points, 1) >=2
                lines = [points(1:end-1, :) points(2:end, :)];
                frame = insertShape(frame, 'Line', trajectoryPoints{i}, ...
                                'Color', 'red', ...
                                'LineWidth', 3);
            end

        if ~isempty(stats{i})
            frame = insertObjectAnnotation(frame, 'rectangle', stats{i}(1).BoundingBox, 'ball');
        end


        set(hImgs(i), 'CData', frame);
    end
    drawnow;
end

fclose(fileID);
for cam_idx = 1:6
    if ~isempty(trajectoryPoints{cam_idx})
        filename = sprintf('trajectory_cam%d.csv', cam_idx-1);
        writematrix(trajectoryPoints{cam_idx}, filename);
        fprintf('Trajectory CSV saved: %s\n', filename);
    end
end
toc;