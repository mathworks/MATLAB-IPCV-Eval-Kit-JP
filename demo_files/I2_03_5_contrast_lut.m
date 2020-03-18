%% コントラスト調整 用の各種関数 %%%%%%%%
clear;clc;close all;imtool close all

%% 画像読込み
G = rgb2gray(imread('I2_03_peppers_low.png'));  % グレースケールへ変換
figure;imshow(G);

%% ルックアップテーブルの作成 (画像がuint8の場合、uint8の256要素のテーブルを作成)
in  = [0 1 70 120 180 255];
out = [0 1 15 150 230 255];
figure; plot(in,out); ylim([0 255]);
%% 区分的 3 次エルミート内挿多項式で内挿
LUT = uint8(interp1(in, out, 0:255, 'pchip'));
hold on;
plot(LUT);
hold off;

%% ルックアップテーブル適用 ()
G1 = intlut(G, LUT);
figure;imshow([G, G1]);
%% 終了

% imshowpairは、デフォルトでは輝度がスケーリングされるので注意
% Copyright 2014 The MathWorks, Inc.
