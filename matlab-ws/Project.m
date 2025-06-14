load('cam_all_params.mat')

videoWriters = cell(6,1);
videoReaders = cell(6,1);
ProjectionMatrix; % P cell'ini burada oluşturuyorsan sorun yok
disp('projection matrix done')

fprintf('Video reader ve writer açılıyor\n')
% Video dosyalarını oku ve yazıcıları hazırla
for i = 1:6
    videoReaders{i} = VideoReader(sprintf('cam%d.mp4', i-1));
    videoWriters{i} = VideoWriter(sprintf('output_cam%d.avi', i-1));
    open(videoWriters{i}); % videoWriter'ı açmayı unutma
end

fprintf('kalman filtresi başlatılıyor\n')
% Kalman için durum değişkeni
kalmanFilter = [];
initialized = false;

infoFrameNumber = 0;
% Video akışı döngüsü
while hasFrame(videoReaders{1})
    infoFrameNumber = infoFrameNumber +1;
    disp(infoFrameNumber);
    
    I = cell(6,1);
    validPoints = {};
    validProjections = {};
    validIndices = [];

    
    for i = 1:6
        fprintf('frameler okunuyor\n')
        frame = readFrame(videoReaders{i});
        I{i} = undistortImage(frame, camParams{i});

        [BW, ~] = createMask(I{i});
        stats = regionprops(BW, 'Centroid');

        if ~isempty(stats)
            validPoints{end+1} = stats(1).Centroid;
            validProjections{end+1} = P{i};
            validIndices(end+1) = i;
        end
    end

    
    if length(validPoints) >= 2
        fprintf('point3d hesaplanıyor\n')
        point3d = [];

        for m = 1:length(validPoints)-1
            for n = m+1:length(validPoints)
                fprintf('triangulation hesaplanıyor\n')
                pt3d = triangulateLinear(validPoints{m}, validPoints{n}, ...
                                         validProjections{m}, validProjections{n})
                point3d = [point3d; pt3d]
            end
        end

        point3d = mean(point3d, 1) % Ortalama 3D nokta

        if ~initialized
            % kalmanFilter = configureKalmanFilter('MotionModel', 'ConstantVelocity', ...
            %                                      'InitialLocation', point3d, ...
            %                                      'MotionNoise', [1, 1, 1], ...
            %                                      'MeasurementNoise', 5);
            kalmanFilter = configureKalmanFilter('ConstantVelocity', ...
                                                point3d, [1 1], [1 1], 1);
            initialized = true;
        end

        filteredPos = correct(kalmanFilter, point3d);

    else
        fprintf('point3d hesaplanamadı\n')
        % Yeterli veri yoksa tahmin et
        if initialized
            filteredPos = predict(kalmanFilter);
        else
            filteredPos = [NaN NaN NaN];
        end
    end

    if ~isempty(validIndices)
        fprintf('En yakın kamera bulunuyor\n')
        % En yakın kamerayı bul
        [~, minIdx] = min(vecnorm(cameraPos(validIndices, :) - filteredPos, 2, 2));
        bestCam = validIndices(minIdx);

        % Not: Burada düzeltme: annotationStr içindeki format hatalıydı
        annotationStr = sprintf('X: %.2f\nY: %.2f\nZ: %.2f', ...
                                filteredPos(1), filteredPos(2), filteredPos(3));
        I{bestCam} = insertText(I{bestCam}, [20 20], annotationStr, ...
                                'FontSize', 22, 'BoxColor', 'green');
    end

    % Frame'leri kaydet
    for i = 1:6
        fprintf('frameler kaydediliyor\n')
        writeVideo(videoWriters{i}, I{i});
    end
end

% Videoları kapat
for i = 1:6
    fprintf('videolar kapatılıyor\n')
    close(videoWriters{i});
end
