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

isValid = @(p) ~any(isnan(p)) && any(p);
%%
tic;
zz = 1;
while all(cellfun(@hasFrame, videos))
    fprintf('FRAME NO: %d\n', zz)
    zz = zz +1;
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
        else
            pt(i, :) = [NaN NaN];            
        end

        if pt(i,:) ~= [0, 0]
            if isempty(trajectoryPoints{i})
                trajectoryPoints{i}(1, :) = pt(i, :);
            else
                trajectoryPoints{i}(end+1, :) = pt(i, :);
            end
        end

		

        if i == 2
            %if ~any(isnan(pt(1, :))) && ~any(isnan(pt(2, :)))
			if isValid(pt(1, :)) && isValid(pt(2, :))
                pt3d(1, :) = triangulateLinear(pt(1,:), pt(2,:), P{1}, P{2});
            else
                pt3d(1, :) = [NaN, NaN, NaN];
            end
            fprintf('i: 1, pt3d: %f\n', pt3d(1, 1));

        elseif i == 3
            %if ~any(isnan(pt(2, :))) && ~any(isnan(pt(3, :)))
            if isValid(pt(2, :)) && isValid(pt(3, :))
				pt3d(2, :) = triangulateLinear(pt(2,:), pt(3,:), P{2}, P{3});
            else
                pt3d(2, :) = [NaN, NaN, NaN];
            end
            fprintf('i: 2, pt3d: %f\n', pt3d(2, 1));

        elseif i == 4
            %if ~any(isnan(pt(3, :))) && ~any(isnan(pt(4, :)))
            if isValid(pt(3, :)) && isValid(pt(4, :))
				pt3d(3, :) = triangulateLinear(pt(3,:), pt(4,:), P{3}, P{4});
            else
                pt3d(3, :) = [NaN, NaN, NaN];
            end
            fprintf('i: 3, pt3d: %f\n', pt3d(3, 1));

        elseif i == 5
            %if ~any(isnan(pt(4, :))) && ~any(isnan(pt(5, :)))
            if isValid(pt(4, :)) && isValid(pt(5, :))
				pt3d(4, :) = triangulateLinear(pt(4,:), pt(5,:), P{4}, P{5});
            else
                pt3d(4, :) = [NaN, NaN, NaN];
            end
            fprintf('i: 4, pt3d: %f\n', pt3d(4, 1));

        elseif i == 6
            %if ~any(isnan(pt(5, :))) && ~any(isnan(pt(6, :)))
            if isValid(pt(5, :)) && isValid(pt(6, :))
				pt3d(5, :) = triangulateLinear(pt(5,:), pt(6,:), P{5}, P{6});
            else
                pt3d(5, :) = [NaN, NaN, NaN];
            end
            fprintf('i: 5, pt3d: %f\n', pt3d(5, 1));

            %if ~any(isnan(pt(6, :))) && ~any(isnan(pt(1, :)))
            if isValid(pt(6, :)) && isValid(pt(1, :))
				pt3d(6, :) = triangulateLinear(pt(6,:), pt(1,:), P{6}, P{1});
            else
                pt3d(6, :) = [NaN, NaN, NaN];
            end
            fprintf('i: 6, pt3d: %f\n', pt3d(6, 1));
        end
    end

    coordinate = mean(pt3d, 1, 'omitnan');
    fprintf('MEAN X: %f\n\n', coordinate(1,1));
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

%%
data_coordinate = readmatrix('output.csv');
figure;
plot3(data_coordinate(:,1), data_coordinate(:,2), data_coordinate(:,3), 'r.-', 'LineWidth',2, 'MarkerSize',5);
% fig = figure
% plot3(data_coordinate(:,1), data_coordinate(:,2), data_coordinate(:,3), ...
%       '.', 'Color', [0.8 0.2 0.2], 'MarkerSize', 2);
grid on;
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');
title('3D projection of ball');
view(3);
axis equal;
%exportgraphics(fig, 'ball_trajectory_before_highres.png', 'Resolution', 600);
%%

% figure;
% plot(data_coordinate(:,1));
% figure;
% plot(data_coordinate(:,2));
% figure;
% plot(data_coordinate(:,3));
%%
x_smooth = smooth_linear(data_coordinate(:,1), 20, 2);
y_smooth = smooth_linear(data_coordinate(:,2), 20, 2);
z_smooth = smooth_linear(data_coordinate(:,3), 20, 2);
%%
figure;
plot(1:length(data_coordinate(:,1)), data_coordinate(:,1), 'r', 1:length(x_smooth), x_smooth, 'b');
legend('Orijinal', 'Düzeltilmiş');
title('X Doğrusallık Düzeltme');
figure;
plot(1:length(data_coordinate(:,2)), data_coordinate(:,2), 'r', 1:length(y_smooth), y_smooth, 'b');
legend('Orijinal', 'Düzeltilmiş');
title('Y Doğrusallık Düzeltme');
figure;
plot(1:length(data_coordinate(:,3)), data_coordinate(:,3), 'r', 1:length(z_smooth), z_smooth, 'b');
legend('Orijinal', 'Düzeltilmiş');
title('Z Doğrusallık Düzeltme');
%%
figure;
plot3(x_smooth, y_smooth, z_smooth, 'r.-', 'LineWidth',2, 'MarkerSize',5);
% fig = figure;
% plot3(x_smooth, y_smooth, z_smooth, ...
%       '.', 'Color', [0.2 0.2 0.8], 'MarkerSize', 2);
grid on;
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');
title('3D projection of ball');
view(3);
axis equal;
% exportgraphics(fig, 'ball_trajectory_after_highres.png', 'Resolution', 600);
%%
fig = figure;
hold on;
plot3(data_coordinate(:,1), data_coordinate(:,2), data_coordinate(:,3), ...
      '.', 'Color', [0.8 0.2 0.2], 'MarkerSize', 2);  % Orijinal (kırmızımsı)

plot3(x_smooth, y_smooth, z_smooth, ...
      '.', 'Color', [0.2 0.2 0.8], 'MarkerSize', 2);  % Yumuşatılmış (mavimsi)

xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z (m)');
title('Nokta Bulutu: Orijinal vs Yumuşatılmış');
legend('Orijinal', 'Yumuşatılmış');
view(3);
axis equal;
grid on;
hold off;

% exportgraphics(fig, 'ball_trajectory_comparison_highres.png', 'Resolution', 600);
