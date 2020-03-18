%% ボリュームデータの計量

%% 半径5と10の球体を作成
[x,y,z] = meshgrid(1:50,1:50,1:50);
bw1 = sqrt((x-10).^2 + (y-15).^2 + (z-35).^2) < 5;
bw2 = sqrt((x-20).^2 + (y-30).^2 + (z-15).^2) < 10;
bw = bw1 | bw2;
figure
isosurface(bw)
alpha 0.3;
axis equal;

%% 重心と半径を計算
s = regionprops3(bw,"Centroid","PrincipalAxisLength");
centers = s.Centroid
diameters = mean(s.PrincipalAxisLength,2)
radii = diameters/2

[x,y,z] = sphere;
hold on 
for k = 1:size(s,1)
    surf(x*radii(k)+centers(k,1),y*radii(k)+centers(k,2),z*radii(k)+centers(k,3));
end

%%
% Copyright 2018 The MathWorks, Inc.