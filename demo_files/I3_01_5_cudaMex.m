%% 画像処理をGPU上で実行
% 一部の処理について、CUDA MEXを生成して統合

clear all, close all, clc

%% 画像データ読み込み
imCPU = imread('concordaerial.png');

%% データをGPUに転送
imGPU = gpuArray(imCPU);

%% グレースケール変換
imGPUgray = rgb2gray(imGPU);

%% 2値化
imWaterGPU = imGPUgray<70;

%% 細かいノイズ除去
imWaterMask = imopen(imWaterGPU,strel('disk',4));
imWaterMask = bwmorph(imWaterMask,'erode',3);
imshow(imWaterMask)

%% ガウシアンフィルタで画像をぼかす(PCT)
%blurH = fspecial('gaussian',20,5);
%imWaterMask = imfilter(single(imWaterMask)*10, blurH);
imWaterMask2 = myfilter(imWaterMask);

%% 青色の要素を強調
blueChannel  = imGPU(:,:,3);
blueChannel2  = imlincomb(1, blueChannel,6, uint8(imWaterMask2));
imGPU(:,:,3) = blueChannel2;

%% CPUにデータを転送し、結果を表示
outCPU = gather(imGPU);
imshow(outCPU)

%% CUDA MEX生成
cfg = coder.gpuConfig('mex');
cfg.TargetLang = 'C++';
t = coder.typeof(gpuArray(false), [2036 3060]);
codegen -args {t} -config cfg myfilter

%% CUDA MEXを利用してガウシアンフィルタ以降の処理を再実行
% ガウシアンフィルタで画像をぼかす(CUDA MEX)
imWaterMask2 = myfilter_mex(imWaterMask);

%% 青色の要素を強調
blueChannel2  = imlincomb(1, blueChannel,6, uint8(imWaterMask2));
imGPU(:,:,3) = blueChannel2;

%% CPUにデータを転送し、結果を表示
outCPU2 = gather(imGPU);
imshowpair(outCPU, outCPU2, 'montage')

%% 
% Copyright 2019 The MathWorks, Inc.