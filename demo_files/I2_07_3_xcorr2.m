%% 正規化された 2次元相互相関
clear all;clc;close all;imtool close all

%% 画像の読込み・表示
BW = imread('text.png');
BW(60:end,:) = [];
figure;imshow(BW);

%% テンプレートの作成・表示
tPlate = BW(32:46,88:98);
figure, imshow(tPlate);

%% 正規化された 2次元相互相関
corr = normxcorr2(tPlate, BW);        % 片側 (aのサイズ-1)/2 づつ大きくなる
corr1 = corr(8:66, 6:261);            % 元のサイズと同じに抜き出し
figure;surf(corr1); shading interp;
set(gca, 'Ydir', 'reverse');          % 左上を原点に

%% 相関の高いところを検出
corrLoc = corr1 > 0.95;
[row, col] = find(corrLoc)
corrLoc1 = [col,row]
I = insertMarker(im2uint8(BW), corrLoc1, 'Circle','Color','red');
figure; imshow(I);

%%
% Copyright 2014 The MathWorks, Inc.


