% % 6 videoyu yükle
% videos = cell(1,6);
% for i = 1:6
%     videos{i} = VideoReader(['cam' num2str(i-1) '.mp4']);
% end

% % Arayüz: tek bir figure, 2x3 subplot
% figure;
% for i = 1:6
%     subplot(2,3,i);
%     hAxes(i) = gca;
%     hImgs(i) = imshow(readFrame(videos{i}));
%     title(['Cam ' num2str(i-1)]);
% end

% % Ana döngü
% while all(cellfun(@hasFrame, videos))
%     for i = 1:6
%         frame = readFrame(videos{i});

%         % --- Burada nesne takibi yapılabilir ---
%         % örn: center = detectBall(frame); marker koy

%         set(hImgs(i), 'CData', frame);
%     end
%     drawnow;
% end
%%
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
%%
stats = cell(6,1);
pt = zeros(6,2);  
pt3d = zeros(6,3);
distanceInMeters = zeros(6,1);

%videos = cell(1,6);
photos = cell(1,6);
for i = 1:6
    %videos{i} = VideoReader(['cam' num2str(i-1) '.mp4']);
    photos{i} = imread(['cam' num2str(i-1) '.png']);
end


figure('Units','normalized','Position',[0 0 1 1]);  
t = tiledlayout(2,3,'TileSpacing','none','Padding','none');

for i = 1:6
    nexttile;
    hImgs(i) = imshow(photos{i});
    title(['\fontsize{25}Cam ' num2str(i-1)]);
end


while true
    for i = 1:6
        frame = photos{i}; 
        frame = undistortImage(frame, camParams{i});
        [BW, ~] = createMask(frame);
        [labeled, ~] = bwlabel(BW);
        stats{i} = regionprops(labeled, 'Centroid', 'BoundingBox');

        pt(i, :) = stats{i}(1).Centroid;
        
        if i == 2
            %pt3d(1, :) = triangulate(pt(1,:), pt(2,:), stereoParams_01);
            pt3d(1, :) = triangulateLinear(pt(1,:), pt(2,:), P{1}, P{2});
        elseif i == 3
            %pt3d(2, :) = triangulate(pt(2,:), pt(3,:), stereoParams_12);
            pt3d(2, :) = triangulateLinear(pt(2,:), pt(3,:), P{2}, P{3});
        elseif i == 4
            %pt3d(3, :) = triangulate(pt(3,:), pt(4,:), stereoParams_23);
            pt3d(3, :) = triangulateLinear(pt(3,:), pt(4,:), P{3}, P{4});
        elseif i == 5
            %pt3d(4, :) = triangulate(pt(4,:), pt(5,:), stereoParams_34);
            pt3d(4, :) = triangulateLinear(pt(4,:), pt(5,:), P{4}, P{5});
        elseif i == 6
            %pt3d(5, :) = triangulate(pt(5,:), pt(6,:), stereoParams_45);
            %pt3d(6, :) = triangulate(pt(6,:), pt(1,:), stereoParams_50);
            pt3d(5, :) = triangulateLinear(pt(5,:), pt(6,:), P{5}, P{6});
            pt3d(6, :) = triangulateLinear(pt(6,:), pt(1,:), P{6}, P{1});
        end
    end
    coordinate = mean(pt3d, 1);
    distanceInMeters = sqrt(coordinate(1)^2 + coordinate(2)^2 + coordinate(3)^2);
    annStr = sprintf('X: %.2f\nY: %.2f\nZ: %.2f\nDistance to Origin: %.4f m', ...
                                mean(pt3d(:, 1)), mean(pt3d(:, 2)), mean(pt3d(:, 3)), distanceInMeters);

    for i = 1:6
        frame = photos{i};
        %distanceInMeters(i) = norm(pt3d(i, :));
        % annStr = sprintf('X: %.2f\nY: %.2f\nZ: %.2f\nDistance: %.4f m', ...
        %                         pt3d(i, 1), pt3d(i, 2), ...
        %                         pt3d(i, 3), distanceInMeters(i));
        frame = insertObjectAnnotation(frame, 'rectangle', stats{i}(1).BoundingBox, 'ball');
        frame = insertText(frame, [20 20], annStr, 'FontSize', 45, 'BoxColor', 'white', 'BoxOpacity', 0.5);



        set(hImgs(i), 'CData', frame);
    end
    drawnow;
end