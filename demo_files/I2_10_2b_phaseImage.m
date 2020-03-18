%% 位相画像の生成
clear;clc;close all;imtool close all

%% 画像の読込み
G = imread('coins.png');
figure;imshow(G);

%% 2次元のFFT計算：左上隅がゼロ周波数係数(DC成分)
F = fft2(G);
figure;imshow(log(abs(F)), []);colormap(jet); colorbar;    % DC成分が左上隅

%% fftshift関数を用い、ゼロ周波数係数(DC成分)を左上隅から、中心へ移動
%     第一象限と第三象限、第二象限と第四象限を入れ替え
Fs = fftshift(F);
figure;imshow(log(abs(Fs)), []);colormap(jet); colorbar;

%% 各成分値を振幅で正規化 (全ての周波数成分が同じ振幅)
Fn = F ./ abs(F);

%% 逆フーリエ変換
Gr = ifft2(Fn);
figure; imshow(Gr, []);

%% 終了









%%
% Copyright 2015 The MathWorks, Inc.


