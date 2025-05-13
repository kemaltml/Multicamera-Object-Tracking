% Camera distances and positions
tic;
dists = [8.96, 4.82, 8.97, 7.99, 4.85, 6.53];
positions = [
    0,   0, 3;
    7.5, 0, 3;
    15,  0, 3;
    15,  4, 3;
    7.5, 8, 3;
    0,   7, 3
];

% Brute-force grid search (coarse resolution)
minError = Inf;
bestPoint = [0, 0, 0];
for x = 7:0.001:8
    for y = 4:0.001:5
        for z = 0:0.001:0.3
            fprintf('x: %.3f  y: %.3f  z: %.3f', x, y, z)
            err = 0;
            for i = 1:6
                dx = x - positions(i,1);
                dy = y - positions(i,2);
                dz = z - positions(i,3);
                dist = sqrt(dx^2 + dy^2 + dz^2);
                err = err + (dist - dists(i))^2;
            end
            if err < minError
                minError = err;
                bestPoint = [x, y, z];
            end
            fprintf('  err: %.2f  min_err: %.4f  bestx: %.4f  besty: %.4f  bestz: %.4f\n', err, minError, bestPoint(1), bestPoint(2), bestPoint(3))
        end
    end
end
elapsed = toc;
fprintf('Estimated Position (brute-force):\n x = %.2f\n y = %.2f\n z = %.2f\n', ...
    bestPoint(1), bestPoint(2), bestPoint(3));
fprintf('time: %.3f seconds', elapsed)