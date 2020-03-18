%% 画像の二値化･適応二値化
clc;clear;close all;imtool close all;

%% 画像の読込み･表示 %%%%%%%%%%%%%%%%%%%%%%%
G = imread('coins.png');
figure; imshow(G);

%% Otsu法により、大局的しきい値により画像を二値化
BW = imbinarize(G);
figure; imshow(BW);

%% 穴を埋める
BWf = imfill(BW, 'holes');
figure; imshow(BWf);

%% 画像の読込み･表示 %%%%%%%%%%%%%%%%%%%%%%%%
G = imread('printedtext.png');
figure; imshow(G);

%% 輝度の局所平均を用い、画素単位で適応しきい値計算
T = adaptthresh(G, 0.4, 'ForegroundPolarity','dark');  % 黒い部分が前景
figure; imshow(T);  % しきい値の可視化

%% 算出したしきい値で、画像を二値化･表示
BW = imbinarize(G, T);
imshow([G; BW*256]); truesize; shg;     % 原画像を結果を、縦に並べて表示

%% 終了











%% 別の画像の読込み･表示 %%%%%%%%%%%%%%%%%%
G = imread('rice.png');
figure; imshow(G);

%% 画像を適応二値化･表示
BW = imbinarize(G, 'adaptive', 'sensitivity',0.4);
figure; imshowpair(G, BW, 'montage');

%% Copyright 2016 The MathWorks, Inc.
