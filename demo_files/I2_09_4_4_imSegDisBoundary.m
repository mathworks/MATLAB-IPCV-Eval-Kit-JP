%% 測地線距離ベースのカラーセグメンテーション
%     開始領域として、数百画素以上を推奨
clc;clear;close all;imtool close all;

%% 画像の読込み・表示
RGB = imread('yellowlily.jpg');
figure;imshow(RGB);

%% 前景指定：開始領域   （複数領域も可）
%    roipoly, imfreehand, imrect, impoly, imellipse も使用可
%bbox1 = [700 350 820 775];   % [左上行 左上列 右下行 右下列]
BW1 = false(size(RGB(:,:,1)));
BW1(700:820, 350:775) = true;
hold on; visboundaries(BW1, 'Color','r');

%% 背景指定：開始領域
bbox2 = [1230 90 1420 1000];
BW2 = false(size(RGB(:,:,1)));
BW2(bbox2(1):bbox2(3),bbox2(2):bbox2(4)) = true;
visboundaries(BW2, 'Color','b');shg;

%% セグメンテーションの実行
%     YCbCr空間へ変換後処理される
[L,P] = imseggeodesic(RGB,BW1,BW2);
figure; imshow(P(:,:,1))          % 前景の確率

%% 結果の表示
figure; imshow(label2rgb(L))

%% 求まった領域境界を表示
figure; imshow(RGB); hold on;
visboundaries(L==min(L(:)), 'Color','r');

%%
% Copyright 2015 The MathWorks, Inc.

