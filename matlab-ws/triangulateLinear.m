function pt3d = triangulateLinear(pt1, pt2, P1, P2)
    A = [
        pt1(1)*P1(3,:) - P1(1,:);
        pt1(2)*P1(3,:) - P1(2,:);
        pt2(1)*P2(3,:) - P2(1,:);
        pt2(2)*P2(3,:) - P2(2,:);
    ];
    [~, ~, V] = svd(A);
    X = V(:, end);
    pt3d = X(1:3) ./ X(4);   
end

