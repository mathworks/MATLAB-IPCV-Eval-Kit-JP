clear;clc;close all;imtool close all
%% 1次元Low Pass Filter設計
N = 12;            % 次数
Fpass = 0.3;       % 通過帯域周波数
Fstop = 0.35;      % 遮断帯域周波数 
Wpass = 1;         % 通過帯域重み
Wstop = 1;         % 遮断帯域重み
b = firls(N,[0 Fpass Fstop 1],[1 1 0 0],[Wpass Wstop]) %最小二乗  線形位相 FIR フィルターの設計 (理想特性からの重み付き積分二乗誤差を最小に)
%% 1次元フィルタ周波数応答表示
freqz(b,1) 

%% 上記のことを、FDAToolにより設計する場合
fdatool       % 設計が完了後、ファイル -> エクスポート

%% 1次元フィルタの2次元化
H2 = ftrans2(b);    % 1次元FIRフィルタから、円対称2次元フィルタ設計
figure,freqz2(H2)   % 2次元フィルタ周波数応答表示

%% 画像の読込み
I = imread('cameraman.tif');
figure;imshow(I);
%% フィルタ処理
If = imfilter(I,H2);
imshow([I;If]);shg

%% 
% Copyright 2014 The MathWorks, Inc.

