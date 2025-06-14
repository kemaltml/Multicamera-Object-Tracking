function [finalPoint, confidence] = fuseWithCameraPoses(pt, stereoParams)
    % MATLAB fusion fonksiyonu - düzeltilmiş versiyon
    
    % Kamera pozisyonları ve açıları
    cameraPos = [
        0   0  3;     % cam0
        7.5 0  3;     % cam1  
        15  0  3;     % cam2
        15  4  3;     % cam3
        7.5 8  3;     % cam4
        0   7  3;     % cam5
    ];
    
    cameraAng = [
       -120  45   0;   % cam0
       -120   0   0;   % cam1
       -120 -45   0;   % cam2
          0 -120 -180; % cam3
        120   0  90;   % cam4
        -30 120   0;   % cam5
    ];
    
    % Her stereo çift için global 3D point hesapla
    globalPoints = zeros(6, 3);
    validTriangulations = false(6, 1);
    
    for i = 1:6
        cam1_idx = i;
        cam2_idx = mod(i, 6) + 1;
        
        try
            % Doğru pt indexing: pt(idx, :) - tüm satırı al
            pt1 = pt(cam1_idx, :);  % [x, y] koordinatları
            pt2 = pt(cam2_idx, :);  % [x, y] koordinatları
            
            fprintf('Triangulating cam%d-cam%d: pt1=[%.1f,%.1f], pt2=[%.1f,%.1f]\n', ...
                   cam1_idx-1, cam2_idx-1, pt1(1), pt1(2), pt2(1), pt2(2));
            
            % Local triangulation (cam1 koordinat sisteminde)
            localPoint = triangulate(pt1, pt2, stereoParams{i});
            
            % cam1'in world pose'unu al
            angles = deg2rad(cameraAng(cam1_idx, :));
            R_world_to_cam = eul2rotm(angles, 'XYZ');
            R_cam_to_world = R_world_to_cam';  % Transpose
            t_cam_world = cameraPos(cam1_idx, :)';
            
            % Local point'i global'e dönüştür
            globalPoints(i, :) = (R_cam_to_world * localPoint' + t_cam_world)';
            validTriangulations(i) = true;
            
            fprintf('  -> Local: [%.2f, %.2f, %.2f], Global: [%.2f, %.2f, %.2f]\n', ...
                   localPoint, globalPoints(i, :));
                   
        catch ME
            fprintf('Triangulation failed for cam%d-cam%d: %s\n', ...
                   cam1_idx-1, cam2_idx-1, ME.message);
            globalPoints(i, :) = [NaN, NaN, NaN];
            validTriangulations(i) = false;
        end
    end
    
    % Sadece geçerli triangulation'ları kullan
    validPoints = globalPoints(validTriangulations, :);
    numValid = sum(validTriangulations);
    
    fprintf('\nValid triangulations: %d/6\n', numValid);
    
    if numValid >= 2
        % Outlier filtreleme
        center = mean(validPoints, 1);
        distances = sqrt(sum((validPoints - center).^2, 2));
        
        if numValid > 2
            threshold = mean(distances) + 2*std(distances);
            outlierMask = distances < threshold;
            finalValidPoints = validPoints(outlierMask, :);
        else
            finalValidPoints = validPoints;
        end
        
        % Final fusion
        finalPoint = mean(finalValidPoints, 1);
        confidence = size(finalValidPoints, 1) / 6;
        
    elseif numValid == 1
        finalPoint = validPoints(1, :);
        confidence = 1/6;
        
    else
        finalPoint = [NaN, NaN, NaN];
        confidence = 0;
    end
    
    fprintf('Final position: [%.2f, %.2f, %.2f]\n', finalPoint);
    fprintf('Distance from origin: %.2f\n', norm(finalPoint));
    fprintf('Confidence: %.2f\n', confidence);
end
