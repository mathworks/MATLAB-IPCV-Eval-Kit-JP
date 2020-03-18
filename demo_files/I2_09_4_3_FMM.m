%% 高速マーチング法を用いた、画像の領域分割
clc;close all;imtool close all;clear;

%% 画像の読込み
G = imread('cameraman.tif');
figure; imshow(G);

%% 開始位置を指定する為の二値画像作成
seed = false(size(G));      % 全て黒の画像の作成
imshow(seed); shg;          % 表示
%%
seed(170:180, 70:80) = true;  % x=70~80, y=170~180 の領域を白に
figure; imshowpair(G, seed, 'montage');shg;   % 並べて表示

%% [ステップ１] 重み配列を計算：各画素の勾配の逆数 %%%%%%%%%%%%%%%
%    出力(重み)は勾配の大きさに反比例：エッジ=>重み小
sigma = 2;    % ガウシアンの標準偏差
W = gradientweight(G, sigma);
figure, imshowpair(G, log(W), 'montage');    % 自然対数スケールで表示

%% [ステップ２] 求めた重みを利用して、セグメンテーション
thresh = 0.1;
[BW, D] = imsegfmm(W, seed, thresh);
figure; imshow(D);   % 計算された、最大1に規格化された測地線距離行列（Seedからそのピクセルまで。重みを考慮）

%% セグメンテーション結果
figure; imshow(BW)


%% 重み(コストの逆)配列を計算：開始点画素値との差から計算
%    seed領域の平均を使用、出力(重み)は差に反比例：差が小=>重み大
W = graydiffweight(G, seed, 'GrayDifferenceCutoff', 25);   %差の最大は25で飽和
figure, imshowpair(G, log(W), 'montage');    % 自然対数スケールで表示

%% 求めた重みを利用して、セグメンテーション
thresh = 0.01;
[BW, D] = imsegfmm(W, seed, thresh);
figure; imshow(D);   % 計算された、規格化された測地線距離行列（Seedからそのピクセルまで）
%% セグメンテーション結果
imtool(BW)



%%
% Copyright 2015 The MathWorks, Inc.
