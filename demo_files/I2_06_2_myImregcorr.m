% 初期化
clear; clc, close all, imtool close all;

%% Step 1: 画像の読込み･表示
fixed  = imread('I2_06_2_stitch1.png');
moving = imread('I2_06_2_stitch2.png');
figure; imshowpair(moving,fixed,'montage')

%% Step 2: 位相相関を用いた位置ずれの検出
%          （輝度ベースの最適化手法より大きなずれに強く高速）
%          （輝度ベースの最適化手法の初期値に使用）
tform = imregcorr(moving, fixed, 'translation')      % ここでは平行移動のみを仮定
tform.T                                              % 得られた変換行列

%% Step 3: 2つの画像の合成
Rfixed = imref2d(size(fixed));
[movingReg, Rreg] = imwarp(moving,tform);               % 2枚目の画像を幾何学的変換
panorama = imfuse(movingReg,Rreg,fixed,Rfixed,'blend'); % 合成
figure; imshow(panorama);

%% Step 4: 輝度を使った最適化ベースの位置合せアルゴリズムを用い
%           微調整（大きくずれた画像に対しては苦手)
%           位相相関で求めた変換行列を初期値として使用
[optimizer,metric] = imregconfig('monomodal');
movingGray = rgb2gray(moving);
fixedGray  = rgb2gray(fixed);
tformOptim = imregtform(movingGray,fixedGray,'translation',optimizer,metric,'InitialTransformation',tform);
tformOptim.T

[movingRegOptim,RregOptim] = imwarp(moving,tformOptim);
panoramaOptim = imfuse(movingRegOptim,RregOptim,fixed,Rfixed,'blend');
figure; imshow(panoramaOptim);

%% 


%% Copyright 2015 The MathWorks, Inc.

