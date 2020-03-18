clear;clc;close all;imtool close all

%% 2値画像内の全領域の境界をトレース
G = imread('coins.png');
figure;imshow(G);
BW = G > 100;
figure;imshow(BW);

%% boundarymask関数の例:
b = boundarymask(BW);         % 境界をマスクとして生成
Ib = imoverlay(G, b, 'g');    % マスクを画像に上書き
figure; imshow(Ib);           % 表示

%% bwboundary関数の例
b = bwboundaries(BW, 'noholes') % 穴はトレースせず。bはXY座標のリスト
figure;imshow(G);
hold on;
visboundaries(b, 'Color','g');  % Figure上で原画像上に上書き
hold off


%% bwtraceboundary : 2値画像内の一つの境界をトレース
G = imread('coins.png');
figure;imshow(G);
BW = im2bw(G);
imtool(BW);

dim = size(BW)
col = round(dim(2)/2)-90      % トレース開始点座標
row = min(find(BW(:,col)))    % トレース開始点座標
b = bwtraceboundary(BW,[row, col],'N');  % 境界上の点(60,26)から境界に沿ってトレース
hold on;
plot(b(:,2),b(:,1),'g','LineWidth',3);    % visboundaries の使用も可能
plot(col, row,'ro','LineWidth', 6);
hold off;
%% 原画像に上書き
figure;imshow(G);shg;
hold on;
plot(b(:,2),b(:,1),'g','LineWidth',3);
plot(col, row,'ro','LineWidth', 6);
hold off;


%% bwperim : 輪郭だけの2値画像を生成
G = imread('coins.png');
figure;imshow(G);
BW = G > 100;
figure;imshow(BW);

BWb = bwperim(BW);
imshow(BWb);
%% 原画像上に上書き
G(BWb) = 0;
I = cat(3, G+ uint8(BWb*255), G, G);
figure;imshow(I);

%% 終了



%% insertShapeを使った場合
G = imread('coins.png');
figure;imshow(G);
BW = G > 100;
figure;imshow(BW);
b = bwboundaries(BW, 'noholes'); % 穴はトレースせず
I1 = insertShape(G, 'Line', reshape([b{1}(:,2),b{1}(:,1)]',1,[]), 'LineWidth',1, 'SmoothEdges',false);
imtool(I1)



% Copyright 2014 The MathWorks, Inc.
