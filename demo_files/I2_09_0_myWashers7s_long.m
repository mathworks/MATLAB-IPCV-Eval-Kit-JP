clc;close all;imtool close all;clear;

%% 画像の読込み・表示
I = imread('I2_09_0_washers7s.JPG');
imtool(I);

%% 円の検出（c:中心点、r:半径）、描画・表示
[c, r] = imfindcircles(I, [30 45], 'Sensitivity', 0.9);       %デフォルトでは、背景よりも明るいものを探す。半径25~55ピクセル

I1 = insertShape(I, 'Circle', [c, r], 'Color','red', 'LineWidth',3);
I2 = insertText(I1, [20, 400], ['Count: ' num2str(size(c,1))], 'TextColor','white', 'FontSize',24);
figure;imshow(I2);

%% 半径のヒストグラム表示
figure;histogram(r, [1:44]);

%% 大小の大きさを識別し、結果の表示
ind_l = r > 37
I3 = insertShape(I, 'Circle', [c(ind_l,:), r(ind_l)], 'Color','blue', 'LineWidth',3);
I4 = insertShape(I3, 'Circle', [c(~ind_l,:), r(~ind_l)], 'Color','green', 'LineWidth',3);

I5 = insertText(I4, [20, 1], ['Count: Large=' num2str(nnz(ind_l)) ', Small=' num2str(nnz(~ind_l))], 'TextColor','white', 'FontSize',24);
figure;imshow(I5);

%% 終了




% Copyright 2014 The MathWorks, Inc.
%     内部で、rgb2grayでグレースケールに変換
