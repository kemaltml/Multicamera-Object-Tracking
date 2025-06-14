load('cam_all_params.mat')

cameraPos = [ ...
    0 0 3;
    7.5 0 3;
    15 0 3;
    15 4 3;
    7.5 8 3;
    0 7 3];

% cameraAng = [ ...
%    -120 45 0;
%    -120 0 0;
%    -120 -45 0;
%    0 -120 -180;
%    120 0 90;
%    -30 120 0];
cameraAng = [ ...
   120 0 45;
   120 0 0;
   120 0 -45;
   120 0 -90;
   120 0 180;
   120 0 120];

Rs = cell(6, 1); % Rotation
Ts = cell(6, 1); % Translation

for i = 1:6
    angles = deg2rad(cameraAng(i, :));
    R = eul2rotm(angles, 'XYZ');
    Rs{i} = R;
    Ts{i} = -R * cameraPos(i, :)'; 

end

camParams = {cameraParams_0, cameraParams_1, cameraParams_2, cameraParams_3, cameraParams_4, cameraParams_5};
P = cell(6, 1);
for i = 1:6
    K = camParams{i}.IntrinsicMatrix';
    P{i} = K * [Rs{i}, Ts{i}];  % 3x4 Projection Matrix
end


% Rx = [ ...
%       1 0 0
%       0 cos(a) -sin(a)
%       0 sin(a) cos(a) ]

% Ry = [ ...
%       cos(a) 0 sin(a)
%       0 1 0
%       -sin(a) 0 cos(a) ]

% Rz = [ ...
%       cos(a) -sin(a) 0
%       sin(a) cos(a) 0
%       0 0 1]
%%
% 
% %Yeni figür
% figure;
% hold on;
% axis equal;
% grid on;
% xlabel('X'); ylabel('Y'); zlabel('Z');
% title('Kamera Konumları ve Yönleri (3D)');
% 
% % Kameraları çiz
% for i = 1:6
%     % Euler -> Rotasyon matrisi (ZYX sırası)
%     R = eul2rotm(deg2rad(cameraAng(i,:)), 'XYZ');
% 
%     % Kamera pozisyonu
%     pos = cameraPos(i,:);
% 
%     % Kamera çizimi
%     plotCamera('Location', pos, ...
%                'Orientation', R, ...
%                'Size', 1.0, ...
%                'Color', 'r', ...
%                'Opacity', 1);
% 
%     % Kamera yönü (Z ekseni)
%     z_dir = R(:,3);
%     quiver3(pos(1), pos(2), pos(3), ...
%             z_dir(1), z_dir(2), z_dir(3), ...
%             10, 'Color', 'b', 'LineWidth', 2);
% end
% view(3);
%%

% % Yeni figür
% figure;
% hold on;
% axis equal;
% grid on;
% xlabel('X'); ylabel('Y'); zlabel('Z');
% title('Kamera Konumları ve Yönleri (3D)');
% xlim([-10, 25]);
% ylim([-10, 18]);
% 
% % Kameraları çiz
% for i = 1:a
%     % Euler -> Rotasyon matrisi (ZYX sırası)
%     R = eul2rotm(deg2rad(cameraAng(i,:)), 'XYZ');
%     Rn = -R;
%     % Kamera pozisyonu
%     pos = cameraPos(i,:);
% 
%     % Kamera çizimi
%     plotCamera('Location', pos, ...
%                'Orientation', R, ...
%                'Size', 1.0, ...
%                'Color', 'r', ...
%                'Opacity', 1);
% 
%     % Kamera yönü (Z ekseni)
%     % z_dir = R(:,3);
%     % quiver3(pos(1), pos(2), pos(3), ...
%     %         z_dir(1), z_dir(2), z_dir(3), ...
%     %         5, 'Color', 'b', 'LineWidth', 2);
% end
% view(3);