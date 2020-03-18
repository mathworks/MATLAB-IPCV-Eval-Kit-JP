clear;clc;close all;imtool close all

%% 画像の読込・表示、３Dネガネで確認
I1 = rgb2gray(imread('scene_left.png'));
I2 = rgb2gray(imread('scene_right.png'));
figure; imshowpair(I1,I2,'ColorChannels','red-cyan');truesize;

%% 視差画像(Disparityマップ)の計算
d = disparity(I1, I2, 'DisparityRange', [-6 10]);

% -realmax('single') と、振り切れてしまったPixelの値を、
% それ以外のpixelの最小値に置き換える
marker_idx = (d == -realmax('single'));
d(marker_idx) = min(d(~marker_idx));

% 視差画像の表示。カメラに近い画素を、明るく表示。
figure; imshow(mat2gray(d));

%% 表面プロットを使い表示
figure; surf(mat2gray(d));shading interp;xlabel('X');ylabel('Y');axis ij

%% 終了
%  Copyright 2014 The MathWorks, Inc.









%% R2014aより前のバージョンで実行するとき視差画像(Disparityマップ)の計算：R2014aより前のバージョンで実行するとき
%     R2014aで、デフォルトの方式として"SemiGlobal"が追加
d = disparity(I1, I2, 'BlockSize', 35,'DisparityRange', [-6 10], 'UniquenessThreshold', 0);
