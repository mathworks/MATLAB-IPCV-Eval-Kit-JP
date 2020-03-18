clear;clc;close all;imtool close all

%% カラフルな繊維のイメージの読み込み
i = imread('fabric.png');
imtool(i);

%% HSV空間へ変換
iHSV = rgb2hsv(i);
imtool(cat(3, iHSV(:,:,1), iHSV(:,:,3), iHSV(:,:,2)));

%% 緑の葉の部分の抽出
i2 = (0.18 < iHSV(:,:,1)) & (iHSV(:,:,1) < (0.18+0.35)) & ...
     (0.16 < iHSV(:,:,3));
imtool(i2);

%% 小さなごみを除去
i3 = bwareaopen(i2, 10);
imtool(i3);
mask=cat(3, i3, i3, i3);

%% 葉部分のみ表示
i_leaf = i;
i_leaf(~mask) = 0;
figure,imshow(i_leaf);

%%
% Copyright 2014 The MathWorks, Inc.
