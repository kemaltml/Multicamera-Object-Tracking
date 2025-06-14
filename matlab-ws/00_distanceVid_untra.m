clear all;
clc;
tic;
% Load stereo camera parameters
load('cam_all_params.mat');
load('stereoParams_all.mat');
ProjectionMatrix;
fileID = fopen('output.csv', 'w');
 
fprintf(fileID,'x,y,z,d,i\n');


% Read stereo video streams
vid0 = VideoReader('cam0.mp4');
vid1 = VideoReader('cam1.mp4');
vid2 = VideoReader('cam2.mp4');
vid3 = VideoReader('cam3.mp4');
vid4 = VideoReader('cam4.mp4');
vid5 = VideoReader('cam5.mp4');

% Write annotated output
out = VideoWriter('output.avi');

open(out);
% open(out1);
% open(out2);
 

i = 1;
stats = cell(6,1);
pt = zeros(6,2);  % 2D coordinates (x,y)
pt3d = zeros(6,3);
distanceInMeters = zeros(6,1);
% Process frames
while hasFrame(vid0)
    I0 = readFrame(vid0);
    I1 = readFrame(vid1);
    I2 = readFrame(vid2);
    I3 = readFrame(vid3);
    I4 = readFrame(vid4);
    I5 = readFrame(vid5);

    % Undistort
    I0 = undistortImage(I0, cameraParams_0);
    I1 = undistortImage(I1, cameraParams_1);
    I2 = undistortImage(I2, cameraParams_2);
    I3 = undistortImage(I3, cameraParams_3);
    I4 = undistortImage(I4, cameraParams_4);
    I5 = undistortImage(I5, cameraParams_5);

    % Create mask
    [BW0, ~] = createMask(I0);
    [BW1, ~] = createMask(I1);
    [BW2, ~] = createMask(I2);
    [BW3, ~] = createMask(I3);
    [BW4, ~] = createMask(I4);
    [BW5, ~] = createMask(I5);

    % Label and get stats
    [labeled0, ~] = bwlabel(BW0);
    [labeled1, ~] = bwlabel(BW1);
    [labeled2, ~] = bwlabel(BW2);
    [labeled3, ~] = bwlabel(BW3);
    [labeled4, ~] = bwlabel(BW4);
    [labeled5, ~] = bwlabel(BW5);


    stats{1} = regionprops(labeled0, 'Centroid', 'BoundingBox');
    stats{2} = regionprops(labeled1, 'Centroid', 'BoundingBox');
    stats{3} = regionprops(labeled2, 'Centroid', 'BoundingBox');
    stats{4} = regionprops(labeled3, 'Centroid', 'BoundingBox');
    stats{5} = regionprops(labeled4, 'Centroid', 'BoundingBox');
    stats{6} = regionprops(labeled5, 'Centroid', 'BoundingBox');

 
    % Match objects by index with safety checks
    lengths = [length(stats{1}), length(stats{2}), length(stats{3}), ...
               length(stats{4}), length(stats{5}), length(stats{6})];
    numObjects = min(lengths);
    
    % Skip frame if no objects detected in any camera
    % if numObjects == 0
    %     fprintf('Frame %d: No objects detected, skipping...\n', i);
    %     continue;
    % end

    for k = 1:1
        % Safe centroid extraction with fallback values
        try
            if length(stats{1}) >= k
                pt(1, :) = stats{1}(k).Centroid;
            else
                pt(1, :) = [NaN, NaN];
            end
            
            if length(stats{2}) >= k
                pt(2, :) = stats{2}(k).Centroid;
            else
                pt(2, :) = [NaN, NaN];
            end
            
            if length(stats{3}) >= k
                pt(3, :) = stats{3}(k).Centroid;
            else
                pt(3, :) = [NaN, NaN];
            end
            
            if length(stats{4}) >= k
                pt(4, :) = stats{4}(k).Centroid;
            else
                pt(4, :) = [NaN, NaN];
            end
            
            if length(stats{5}) >= k
                pt(5, :) = stats{5}(k).Centroid;
            else
                pt(5, :) = [NaN, NaN];
            end
            
            if length(stats{6}) >= k
                pt(6, :) = stats{6}(k).Centroid;
            else
                pt(6, :) = [NaN, NaN];
            end
        catch ME
            fprintf('Error in centroid extraction: %s\n', ME.message);
            continue;
        end

        % Check if centroids contain valid values before triangulation
        if ~any(isnan(pt(1, :))) && ~any(isnan(pt(2, :)))
            pt3d(1, :) = triangulate(pt(1, :), pt(2, :), stereoParams_01);
        else
            pt3d(1, :) = [NaN, NaN, NaN];
        end
        
        if ~any(isnan(pt(2, :))) && ~any(isnan(pt(3, :)))
            pt3d(2, :) = triangulate(pt(2, :), pt(3, :), stereoParams_12);
        else
            pt3d(2, :) = [NaN, NaN, NaN];
        end
        
        if ~any(isnan(pt(3, :))) && ~any(isnan(pt(4, :)))
            pt3d(3, :) = triangulate(pt(3, :), pt(4, :), stereoParams_23);
        else
            pt3d(3, :) = [NaN, NaN, NaN];
        end
        
        if ~any(isnan(pt(4, :))) && ~any(isnan(pt(5, :)))
            pt3d(4, :) = triangulate(pt(4, :), pt(5, :), stereoParams_34);
        else
            pt3d(4, :) = [NaN, NaN, NaN];
        end
        
        if ~any(isnan(pt(5, :))) && ~any(isnan(pt(6, :)))
            pt3d(5, :) = triangulate(pt(5, :), pt(6, :), stereoParams_45);
        else
            pt3d(5, :) = [NaN, NaN, NaN];
        end
        
        if ~any(isnan(pt(6, :))) && ~any(isnan(pt(1, :)))
            pt3d(6, :) = triangulate(pt(6, :), pt(1, :), stereoParams_50);
        else
            pt3d(6, :) = [NaN, NaN, NaN];
        end
        
        % Calculate distances only for valid 3D points
        for j = 1:6
            if ~any(isnan(pt3d(j, :)))
                distanceInMeters(j) = norm(pt3d(j, :)) / 100;  % if output is in cm
            else
                distanceInMeters(j) = Inf;  % Set to infinity for invalid points
            end
        end
        
        % Check if any valid distances exist
        validDistances = distanceInMeters(~isinf(distanceInMeters));
        if isempty(validDistances)
            fprintf('Frame %d: No valid 3D points detected, skipping annotation...\n', i);
            % Use a default frame for output (e.g., first camera)
            out_frame = I0;
            annStr = 'No object detected';
        else
            minDistance = min(validDistances);
            [~, closestPointIndex] = min(distanceInMeters);
            
            % Only annotate if the closest point is valid
            if ~any(isnan(pt3d(closestPointIndex, :)))
                annStr = sprintf('X: %.2f\nY: %.2f\nZ: %.2f\nDistance: %.2f m', ...
                                pt3d(closestPointIndex, 1), pt3d(closestPointIndex, 2), ...
                                pt3d(closestPointIndex, 3), minDistance);
            else
                annStr = 'Object tracking lost';
            end
        end

        fprintf(fileID,'%.2f,%.2f,%.2f,%.2f,%d\n', ...
                                pt3d(closestPointIndex, 1), pt3d(closestPointIndex, 2), ...
                                pt3d(closestPointIndex, 3), minDistance, closestPointIndex-1);
        
        % Check if we have a valid closest point for annotation
        if exist('closestPointIndex', 'var') && ~isempty(validDistances)
            if closestPointIndex == 1 && length(stats{1}) >= 1
                out_frame = insertObjectAnnotation(I0, 'rectangle', stats{1}(1).BoundingBox, 'ball');
                out_frame = insertText(out_frame, [1000 20], 'CAM0', 'FontSize', 22, 'BoxColor', 'yellow' );
                fprintf('Cam: %d\n', 0);
            elseif closestPointIndex == 2 && length(stats{2}) >= 1
                out_frame = insertObjectAnnotation(I1, 'rectangle', stats{2}(1).BoundingBox, 'ball');
                out_frame = insertText(out_frame, [1000 20], 'CAM1', 'FontSize', 22, 'BoxColor', 'yellow' );
                fprintf('Cam: %d\n', 1);
            elseif closestPointIndex == 3 && length(stats{3}) >= 1
                out_frame = insertObjectAnnotation(I2, 'rectangle', stats{3}(1).BoundingBox, 'ball');
                out_frame = insertText(out_frame, [1000 20], 'CAM2', 'FontSize', 22, 'BoxColor', 'yellow' );
                fprintf('Cam: %d\n', 2);
            elseif closestPointIndex == 4 && length(stats{4}) >= 1
                out_frame = insertObjectAnnotation(I3, 'rectangle', stats{4}(1).BoundingBox, 'ball');
                out_frame = insertText(out_frame, [1000 20], 'CAM3', 'FontSize', 22, 'BoxColor', 'yellow' );
                fprintf('Cam: %d\n', 3);
            elseif closestPointIndex == 5 && length(stats{5}) >= 1
                out_frame = insertObjectAnnotation(I4, 'rectangle', stats{5}(1).BoundingBox, 'ball');
                out_frame = insertText(out_frame, [1000 20], 'CAM4', 'FontSize', 22, 'BoxColor', 'yellow' );
                fprintf('Cam: %d\n', 4);
            elseif closestPointIndex == 6 && length(stats{6}) >= 1
                out_frame = insertObjectAnnotation(I5, 'rectangle', stats{6}(1).BoundingBox, 'ball');
                out_frame = insertText(out_frame, [1000 20], 'CAM5', 'FontSize', 22, 'BoxColor', 'yellow' );
                fprintf('Cam: %d\n', 5);
            else
                % Default to first camera if annotation fails
                out_frame = I0;
                fprintf('No Object!');
            
            end
        else
            % No valid objects detected, use first camera
            out_frame = I0;
        end
    end

    % Write frame
    out_frame = insertText(out_frame, [20 20], annStr, 'FontSize', 22, 'BoxColor', 'white' );
    writeVideo(out, out_frame);
    % Optional: show live
    fprintf('Frame: %d\n', i);
    % imshowpair(I0_annotated, I1_annotated, 'montage');
    % drawnow;
    i= i+1;
end

% Finish
close(out);
fclose(fileID);
toc;

% Elapsed time is 458.891998 seconds.
% 7m 38.9s
