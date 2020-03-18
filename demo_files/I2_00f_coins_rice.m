% 画像からお米の面積や数を求める
% 初期化
clear; clc, close all, imtool close all;
% 一行づつ順番に実行

%% 画像の2値化処理 %%%%%
I = imread('coins.png');  % ファイルから画像読込み (変数Iへ)
figure; imshow(I);   % Windowを作成し、画像の表示

figure; imhist(I);   % ヒストグラム表示
I2 = I > 100;        % 大小比較演算による画像の二値化
figure; imshow(I2);
I3 = imfill(I2, 'holes'); % 穴の塗りつぶし
figure; imshow(I3);

%% 別の2値化処理と、"位置"や、"面積"の平均の算出 %%%%%
clear all; clc, close all, imtool close all;
I = imread('rice.png'); % ファイルから画像読込み
figure; imshow(I);      % 画像の表示

figure; imhist(I);      % ヒストグラム表示

%%
a = 79;
imshow(I>a);shg;        % 対話的に適切な閾値の探索
%%
figure; imshow(I>150);
figure; surf(double(I));shading interp; % 表面プロット
                                        % 表示をみやすく

Ierode=imerode(I, ones(15));     % 収縮処理による米粒の消去
figure;imshow(Ierode);
figure; ...
surf(double(Ierode),'EdgeColor','none');% 背景表面プロット

I2 = I-Ierode;                             % 背景の除去
figure; surf(double(I2));shading interp; % 表面プロット

figure; imtool(I2);           % imtoolでヒストグラム確認
Ibw = I2 > 50;
figure; imshow(Ibw);
Ibw=bwareaopen(Ibw, 4);       % 細かなノイズの除去
figure; imshow(Ibw);
Iclr=imclearborder(Ibw);      % 切れている(外周接触)米の除去
figure; imshow(Iclr);
stat=regionprops('table', Ibw, 'Area', 'Centroid')  % struct/table, 面積、[x座標, y座標]
A=[stat.Area]                 % 求まった各面積
mean(A)                       % 面積の平均

hist(A);           % もしくはAをワークスペースで選択後、
                   % ツールストリップのhist選択
title('面積分布', 'FontSize',16);
%% 終了




%% Copyright 2013 The MathWorks, Inc.
% This is a demo for thresholding, morphological image processing, blob analysis
%
% Original version can be found by the following command
%     web([docroot '/images/examples/correcting-nonuniform-illumination.html'])
% or in the following URL.
%     http://www.mathworks.com/help/releases/R2012b/images/examples/correcting-nonuniform-illumination_ja_JP.html

