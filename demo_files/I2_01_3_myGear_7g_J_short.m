%% 歯車の欠陥検出
%
% 初期化
clc;close all;imtool close all;clear;

%% [画像の読込み]
G = imread('I2_01_3_gear7g.jpg'); % 変数宣言不要。容易な多次元配列取扱い
imtool(G);                   % 容易な可視化

%% [前処理] 二値(白黒)画像に変換 (プロット->histogramで確認 or imhist(G) )
BW = G > 130;     % 130: 二次元の配列と、数値の比較。自動閾値設定：BW=im2bw(G, graythresh(G));     150
imtool(BW);       % ピクセル値を確認 (0と1の、2値画像)

%% [フィルタ処理]トップハット フィルタ処理で、歯の部分を抽出 （元画像 - Opening画像）
BWtoph = imtophat(BW, strel('Disk',30,8));
imshow(BWtoph); shg;

%% [後処理] 細かなノイズの除去
BWclear = bwareaopen(BWtoph, 50); % 50ピクセル以下のものを削除
imshow(BWclear); shg;

%% [途中結果の可視化] ここまでの結果を、並べて表示
figure; imshowpair(BW, BWclear, 'montage');shg;

%% [途中結果の解析] ２つの画像を重ねて表示
imshowpair(BW, BWclear);shg;   % 白：変化ない部分、緑：元の画像のみに存在

%% [計測] 各歯の面積と中心点の測定
stats = regionprops('table', BWclear, 'Area', 'Centroid')

%% [グラフ化] ヒストグラムの表示 or イメージの領域解析APPS
figure; histogram([stats.Area], [1:179]);

%% [結果の可視化]
ind = find([stats.Area] < 100);  % ベクトルと数値の比較
Gresult2 = insertShape(G, 'Circle', [stats.Centroid(ind,:) 18], 'LineWidth',4, 'Color','red', 'Opacity',1);
Gresult3 = insertText(Gresult2, [10, 10], ['Defect Tooth: indicated by Red Circle'], 'FontSize', 30, 'BoxColor','red', 'BoxOpacity',1);
imshow(Gresult3); shg

%% [終了]
%% [レポート生成]

%% Copyright 2014 The MathWorks, Inc.
%        Masa Otobe (masa.otobe@mathworks.co.jp)
