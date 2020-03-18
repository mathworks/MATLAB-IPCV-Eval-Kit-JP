%% デノイジングCNNをロード('DnCNN')
net = denoisingNetwork('DnCNN');

%% グレイスケール画像を読み込み、ガウシアンノイズ付加
I = imread('cameraman.tif');
noisyI = imnoise(I,'gaussian',0,0.01);
figure
imshowpair(I,noisyI,'montage');
title('Original Image (left) and Noisy Image (right)')

%% デノイジングネットワークを使ってノイズ除去
denoisedI = denoiseImage(noisyI, net);
figure
imshow(denoisedI)
title('Denoised Image')

%% 
% Copyright 2018 The MathWorks, Inc.

