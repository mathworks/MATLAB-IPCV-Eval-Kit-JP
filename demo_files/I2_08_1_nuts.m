%% 木の実等をカウント･赤い粒の平均の大きさ
% 初期化
clear;clc;close all;imtool close all

%% 画像データを読込み
I = imread('I2_08_1_1895cr.jpg');
figure;imshow(I);

%% ２値画像を作成し、物体と背景を識別 %%%%%%%%%%%%%%%%%%
% グレースケールへ変換
G = rgb2gray(I);
figure;imshow(G);

%% 輝度のヒストグラムを確認
figure;imhist(G);

%% 輝度により二値化 (背景が0、物体が1の2値画像作成)
BW = G < 180;      %140から10ずつ、"値のインクリメントおよびセクション実行"
imshow(BW);shg;

%% エッジ検出
BWe = edge(G,'canny', [0.04 0.06], 3);
imshow(BWe);shg;   %拡大して輪郭がつながっていることを確認

%% モルフォロジー処理：線で囲まれている領域を埋める
BWf1 = imfill(BWe, 'holes');
imshow(BWf1); shg;

%% モルフォロジー処理：切れている部分をつなぐ
BWb = bwmorph(BWf1, 'bridge');
imshow(BWb); shg;                     % つながったことを確認

%% 再度、線で囲まれている部分を埋める
BWf2 = imfill(BWb, 'holes');
imshow(BWf2); shg;

% モルフォロジー処理：細かな線(ノイズ)を削除：オープン処理 (収縮後に膨張)
% （他に、bwareaopen()関数で行うことも可能 ）
%% 収縮処理
BWe = bwmorph(BWf2, 'erode');
figure;imshow(BWe); shg;

%% 膨張処理
BWd = bwmorph(BWe, 'dilate');
figure;imshow(BWd); shg;

%% 各領域（blob：白い部分）の形状測定 (面積・中心点)
stats=regionprops('table', BWd, 'Area', 'Centroid')  % R2015a でテーブル出力に対応

%% 個数
size(stats, 1)

%% 面積のヒストグラムをプロット
figure;hist([stats.Area])

%% イメージの解析 アプリケーション で BWdを読込み

%% 終了



%% Copyright 2013 The MathWorks, Inc.
%    Masa Otobe (masa.otobe@mathworks.co.jp)
% 必要なファイル：I2_08_1_1895cr.jpg
