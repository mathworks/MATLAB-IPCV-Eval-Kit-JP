%% コントラスト調整 用の各種関数 %%%%%%%%
clear;clc;close all;imtool close all

%% 画像読込み %%%%%%%%
I = imread('I2_03_peppers_low.png');
Gray = rgb2gray(I);  % グレースケールへ変換
figure;imshow(Gray);

figure;imhist(Gray);     % 輝度値のヒストグラムを表示

%% 低・高輝度で1%飽和するよう自動調整 %%%%%%%%%%%%%%%
Gray1 = imadjust(Gray);
figure;imhist(Gray1);
%% 処理前後の画像を並べて表示
figure;imshow([Gray Gray1]);


%% ヒストグラム均等化を用いたコントラストの強調：ビン間隔の調整をして、フラットになるように
Gray2 = histeq(Gray, 256);
figure;imhist(Gray2);
%% 表示
figure;imshow([Gray1 Gray2]);

%% コントラストに制限を付けた適応ヒストグラム均等化 %%%%%
%     デフォルト：8x8ピクセルのタイル毎にヒストグラム均等化
% フラットなヒストグラム
Gray3 = adapthisteq(Gray,'Distribution','uniform');
figure;imhist(Gray3);
%% 表示
figure;imshow([Gray1 Gray3]);

%% ベル型ヒストグラム
Gray4 = adapthisteq(Gray,'Distribution','rayleigh');
figure;imhist(Gray4);
%% 表示
figure;imshow([Gray3 Gray4]);

%% 曲線ヒストグラム
Gray5 = adapthisteq(Gray,'Distribution','exponential');
figure;imhist(Gray5);
%% 表示
figure;imshow([Gray3 Gray4 Gray5]);

%% 曲線ヒストグラム: コントラスト強調の制限を調整
Gray6 = adapthisteq(Gray,'Distribution','exponential', 'ClipLimit', 1);
figure;imhist(Gray6);
%% 表示
figure;imshow([Gray3 Gray4 Gray5 Gray6]);

%% 終了

% imshowpairは、デフォルトでは輝度がスケーリングされるので注意
% Copyright 2014 The MathWorks, Inc.
