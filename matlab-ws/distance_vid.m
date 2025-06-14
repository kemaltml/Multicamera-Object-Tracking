clear all;
clc;
%%

disp('\nloading params');
tic;
load('cam_all_params.mat');
load('stereoParams_all.mat');
ProjectionMatrix;
fileID = fopen('output.csv', 'w');
 
fprintf(fileID,'x,y,z,d,i\n');
toc;
%%
disp('\nvideo reader');
tic;

vid0 = VideoReader('cam0.mp4');
vid1 = VideoReader('cam1.mp4');
vid2 = VideoReader('cam2.mp4');
vid3 = VideoReader('cam3.mp4');
vid4 = VideoReader('cam4.mp4');
vid5 = VideoReader('cam5.mp4');

out = VideoWriter('output.avi');

open(out);
% open(out1);
% open(out2);
toc;
 %%
tic;

trajectoryPoints = cell(6, 1);
for cam_idx = 1:6
    trajectoryPoints{cam_idx} = NaN(2000, 2);  % [x, y] coordinates
end
fprintf('Trajectory storage initialized for 6 cameras\n');
toc;
%%
i = 1;
stats = cell(6,1);
pt = zeros(6,2);  
pt3d = zeros(6,3);
distanceInMeters = zeros(6,1);

previous_camera_index = 1;  
camera_switch_threshold = 3;  
frames_since_switch = 0;     
trajectory_fade_frames = 10;
%while hasFrame(vid0)
while i <2
    disp('\nread frame');
    tic;
    I0 = readFrame(vid0);
    I1 = readFrame(vid1);
    I2 = readFrame(vid2);
    I3 = readFrame(vid3);
    I4 = readFrame(vid4);
    I5 = readFrame(vid5);
    toc;
    disp('\nundistort Image');
    tic;
    I0 = undistortImage(I0, cameraParams_0);
    I1 = undistortImage(I1, cameraParams_1);
    I2 = undistortImage(I2, cameraParams_2);
    I3 = undistortImage(I3, cameraParams_3);
    I4 = undistortImage(I4, cameraParams_4);
    I5 = undistortImage(I5, cameraParams_5);
    toc;
    disp('\ncreateMAsk');
    tic;
    [BW0, ~] = createMask(I0);
    [BW1, ~] = createMask(I1);
    [BW2, ~] = createMask(I2);
    [BW3, ~] = createMask(I3);
    [BW4, ~] = createMask(I4);
    [BW5, ~] = createMask(I5);
    toc;

    disp('\nlabel');
    tic;
    [labeled0, ~] = bwlabel(BW0);
    [labeled1, ~] = bwlabel(BW1);
    [labeled2, ~] = bwlabel(BW2);
    [labeled3, ~] = bwlabel(BW3);
    [labeled4, ~] = bwlabel(BW4);
    [labeled5, ~] = bwlabel(BW5);
    toc;

    disp('\nstats');
    tic;
    stats{1} = regionprops(labeled0, 'Centroid', 'BoundingBox');
    stats{2} = regionprops(labeled1, 'Centroid', 'BoundingBox');
    stats{3} = regionprops(labeled2, 'Centroid', 'BoundingBox');
    stats{4} = regionprops(labeled3, 'Centroid', 'BoundingBox');
    stats{5} = regionprops(labeled4, 'Centroid', 'BoundingBox');
    stats{6} = regionprops(labeled5, 'Centroid', 'BoundingBox');
    toc;
 
   
    lengths = [length(stats{1}), length(stats{2}), length(stats{3}), ...
               length(stats{4}), length(stats{5}), length(stats{6})];
    numObjects = min(lengths);
    
    
    % if numObjects == 0
    %     fprintf('Frame %d: No objects detected, skipping...\n', i);
    %     continue;
    % end

    disp('\nchech lenght');
    tic
    for k = 1:1
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
        toc;

        % Step 2: Update trajectories within the main loop
        % Append valid centroid positions to their respective trajectoryPoints
        disp('\nstep2');
        tic;
        for cam_idx = 1:6
            % Check if centroid is valid (not NaN) before storing
            if ~any(isnan(pt(cam_idx, :)))
                % Store valid centroid position in trajectory
                if i <= size(trajectoryPoints{cam_idx}, 1)
                    trajectoryPoints{cam_idx}(i, :) = pt(cam_idx, :);
                else
                    % Extend trajectory storage if needed
                    new_size = size(trajectoryPoints{cam_idx}, 1) * 2;
                    temp = NaN(new_size, 2);
                    temp(1:size(trajectoryPoints{cam_idx}, 1), :) = trajectoryPoints{cam_idx};
                    temp(i, :) = pt(cam_idx, :);
                    trajectoryPoints{cam_idx} = temp;
                end
                fprintf('Frame %d, Cam %d: Stored trajectory point (%.2f, %.2f)\n', ...
                        i, cam_idx-1, pt(cam_idx, 1), pt(cam_idx, 2));
            else
                % Store NaN for invalid detections to maintain frame alignment
                if i <= size(trajectoryPoints{cam_idx}, 1)
                    trajectoryPoints{cam_idx}(i, :) = [NaN, NaN];
                end
                fprintf('Frame %d, Cam %d: Invalid centroid, stored NaN\n', i, cam_idx-1);
            end
        end
        toc;

        disp('\ncheck centroid');
        tic;
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
        toc;
        
        disp('\ncalculate distance');
        tic;
        % Calculate distances only for valid 3D points
        for j = 1:6
            if ~any(isnan(pt3d(j, :)))
                distanceInMeters(j) = norm(pt3d(j, :)) / 100;  % if output is in cm
            else
                distanceInMeters(j) = Inf;  % Set to infinity for invalid points
            end
        end
        toc;
        
        % Check if any valid distances exist
        disp('\nvalid istance');
        tic;
        validDistances = distanceInMeters(~isinf(distanceInMeters));
        if isempty(validDistances)
            fprintf('Frame %d: No valid 3D points detected, skipping annotation...\n', i);
            % Use a default frame for output (e.g., first camera)
            out_frame = I0;
            annStr = 'No object detected';
        else
            minDistance = min(validDistances);
            [~, temp_closest_index] = min(distanceInMeters);
            
            % Camera switching logic with stability check
            if temp_closest_index ~= previous_camera_index
                if frames_since_switch >= camera_switch_threshold
                    % Allow camera switch
                    closestPointIndex = temp_closest_index;
                    previous_camera_index = closestPointIndex;
                    frames_since_switch = 0;
                    fprintf('Frame %d: Camera switched to cam %d\n', i, closestPointIndex-1);
                else
                    % Keep using previous camera for stability
                    closestPointIndex = previous_camera_index;
                    frames_since_switch = frames_since_switch + 1;
                end
            else
                % Same camera as previous frame
                closestPointIndex = temp_closest_index;
                frames_since_switch = frames_since_switch + 1;
            end
            
            % Only annotate if the closest point is valid
            if ~any(isnan(pt3d(closestPointIndex, :)))
                annStr = sprintf('X: %.2f\nY: %.2f\nZ: %.2f\nDistance: %.2f m', ...
                                pt3d(closestPointIndex, 1), pt3d(closestPointIndex, 2), ...
                                pt3d(closestPointIndex, 3), minDistance);
            else
                annStr = 'Object tracking lost';
            end
        end
        toc;

        fprintf(fileID,'%.2f,%.2f,%.2f,%.2f,%d\n', ...
                                pt3d(closestPointIndex, 1), pt3d(closestPointIndex, 2), ...
                                pt3d(closestPointIndex, 3), minDistance, closestPointIndex-1);
        
        % Check if we have a valid closest point for annotation
        disp('\nanotate closest point');
        tic;
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
        toc;
    end

    % Step 4: Enhanced trajectory overlay for camera switches
    % Retrieve the camera's trajectoryPoints and overlay its historical path
    disp('\nenhanced trajectory');
    tic;
    if exist('closestPointIndex', 'var') && ~isempty(validDistances)
        % Get the trajectory points for the camera that detected the closest object
        cam_trajectory = trajectoryPoints{closestPointIndex};
        
        % Enhanced trajectory display with continuity assurance
        if ~isempty(cam_trajectory) && size(cam_trajectory, 1) > 1
            % Find valid (non-NaN) trajectory points up to current frame
            current_frame_limit = min(i, size(cam_trajectory, 1));
            valid_indices = find(~isnan(cam_trajectory(1:current_frame_limit, 1)));
            
            if length(valid_indices) > 1
                % Calculate trajectory segments with varying opacity for continuity
                num_segments = length(valid_indices) - 1;
                
                for traj_idx = 1:num_segments
                    point1_idx = valid_indices(traj_idx);
                    point2_idx = valid_indices(traj_idx + 1);
                    
                    point1 = cam_trajectory(point1_idx, :);
                    point2 = cam_trajectory(point2_idx, :);
                    
                    % Create line coordinates [x1 y1 x2 y2]
                    line_coords = [point1(1), point1(2), point2(1), point2(2)];
                    
                    % Calculate line opacity based on recency (newer = more opaque)
                    recency_factor = traj_idx / num_segments;
                    line_width = max(1, round(2 * recency_factor));
                    
                    % Insert line on the output frame with varying thickness
                    out_frame = insertShape(out_frame, 'Line', line_coords, ...
                                          'Color', 'red', 'LineWidth', line_width);
                end
                
                % Add trajectory points as markers for better visibility
                recent_points = valid_indices(max(1, end-5):end);  % Last 5 points
                for point_idx = recent_points
                    if point_idx <= size(cam_trajectory, 1)
                        point_pos = cam_trajectory(point_idx, :);
                        if ~any(isnan(point_pos))
                            % Draw circle marker at trajectory point
                            marker_box = [point_pos(1)-3, point_pos(2)-3, 6, 6];
                            out_frame = insertShape(out_frame, 'FilledCircle', ...
                                                  [point_pos(1), point_pos(2), 3], ...
                                                  'Color', 'yellow', 'Opacity', 0.7);
                        end
                    end
                end
                
                fprintf('Frame %d: Enhanced trajectory overlay - %d segments, %d markers for cam %d\n', ...
                        i, num_segments, length(recent_points), closestPointIndex-1);
            end
        end
        toc;
        
        % Display fade-out trajectory from previous camera during switch
        disp('\nfade out');
        tic;
        if previous_camera_index ~= closestPointIndex && frames_since_switch < trajectory_fade_frames
            prev_cam_trajectory = trajectoryPoints{previous_camera_index};
            if ~isempty(prev_cam_trajectory) && size(prev_cam_trajectory, 1) > 1
                prev_current_limit = min(i, size(prev_cam_trajectory, 1));
                prev_valid_indices = find(~isnan(prev_cam_trajectory(1:prev_current_limit, 1)));
                
                if length(prev_valid_indices) > 1
                    % Fade factor based on frames since switch
                    fade_factor = 1 - (frames_since_switch / trajectory_fade_frames);
                    
                    % Draw fading trajectory from previous camera
                    for traj_idx = 1:(length(prev_valid_indices)-1)
                        point1_idx = prev_valid_indices(traj_idx);
                        point2_idx = prev_valid_indices(traj_idx + 1);
                        
                        point1 = prev_cam_trajectory(point1_idx, :);
                        point2 = prev_cam_trajectory(point2_idx, :);
                        
                        line_coords = [point1(1), point1(2), point2(1), point2(2)];
                        fade_width = max(1, round(2 * fade_factor));
                        
                        % Draw fading previous trajectory in blue
                        out_frame = insertShape(out_frame, 'Line', line_coords, ...
                                              'Color', 'blue', 'LineWidth', fade_width);
                    end
                    
                    fprintf('Frame %d: Fading trajectory from cam %d (fade: %.2f)\n', ...
                            i, previous_camera_index-1, fade_factor);
                end
            end
        end
        toc;
    end

    % Write frame
    disp('\nout frame');
    tic;
    out_frame = insertText(out_frame, [20 20], annStr, 'FontSize', 22, 'BoxColor', 'white' );
    writeVideo(out, out_frame);
    % Optional: show live
    fprintf('Frame: %d\n', i);
    % imshowpair(I0_annotated, I1_annotated, 'montage');
    % drawnow;
    i= i+1;
    toc;
end

% Finish
close(out);
fclose(fileID);

disp('\nsave trajectory');
tic;
% Save trajectory data after processing all frames
fprintf('\nSaving trajectory data...\n');
for cam_idx = 1:6
    % Remove unused pre-allocated rows (NaN rows at the end)
    valid_rows = find(~isnan(trajectoryPoints{cam_idx}(:, 1)), 1, 'last');
    if ~isempty(valid_rows)
        trajectoryPoints{cam_idx} = trajectoryPoints{cam_idx}(1:valid_rows, :);
        fprintf('Cam %d: Saved %d trajectory points\n', cam_idx-1, valid_rows);
    else
        trajectoryPoints{cam_idx} = [];
        fprintf('Cam %d: No valid trajectory points\n', cam_idx-1);
    end
end
toc;
tic;
% Save trajectory data to file
save('trajectory_data.mat', 'trajectoryPoints');
fprintf('Trajectory data saved to trajectory_data.mat\n');

% Optional: Create a CSV file for each camera's trajectory
for cam_idx = 1:6
    if ~isempty(trajectoryPoints{cam_idx})
        filename = sprintf('trajectory_cam%d.csv', cam_idx-1);
        csvwrite(filename, trajectoryPoints{cam_idx});
        fprintf('Trajectory CSV saved: %s\n', filename);
    end
end
toc;


% Elapsed time is 458.891998 seconds.
% 7m 38.9s
