%% ガボールフィルタ
clc;clear;close all;imtool close all;

%% 波長:5pix/cycle、角度:0度 (横)のガボールフィルタのオブジェクトを生成･表示
g1 = gabor(5, 0)
figure; surf(real(g1.SpatialKernel));shading interp; xlabel('X'); ylabel('Y');
             axis ij; box on; colorbar; title('波長:5pix/cycle、角度:0度');
             
%% 画像の読込み･表示
G = imread('testpat1.png');
figure; imshow(G);

%% 画像にガボールフィルタを適応
mag1 = imgaborfilt(G, g1);
figure; imshow(mag1, []);

%% 波長:5,10pix/cycle、角度:0,45度 のガボールフィルタバンクの作成･表示
%      波長により、カーネルのサイズが変化
g2 = gabor([5,10], [0,45])

sizeMax = size(g2(end).SpatialKernel, 1);
figure;
for p = 1:4
    subplot(2,2,p);
    size1 = size(g2(p).SpatialKernel,1);
    a = ones(sizeMax)*0.9;
    a(1:size1, 1:size1) = real(g2(p).SpatialKernel);
    imshow(a, []);
    title(sprintf('波長= %d, 角度 = %d, Kernel size = %d', ...
            g2(p).Wavelength, g2(p).Orientation, size(g2(p).SpatialKernel,1)) );
end

%% 画像にガボールフィルタバンクを適応･表示
mag2 = imgaborfilt(G, g2);

figure;
for p = 1:4
    subplot(2,2,p)
    imshow(mag2(:,:,p),[]);
    title(sprintf('波長= %d, 角度 = %d, Kernel size = %d', ...
            g2(p).Wavelength, g2(p).Orientation, size(g2(p).SpatialKernel,1)) );
end

%%
% Copyright 2014 The MathWorks, Inc.
