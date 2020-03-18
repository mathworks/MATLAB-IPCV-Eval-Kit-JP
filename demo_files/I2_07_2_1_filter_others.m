clear;clc;close all;imtool close all

%% 画像の読込み
Inuts = imread('I2_07_2_1_nuts.png');
figure;imshow(Inuts);

%% 平均化フィルター
Iave    = imfilter(Inuts,fspecial('average',5)); %平均化フィルタ
imshow([Inuts Iave]);truesize;shg;

%% Guided filter (R2014a)
Iguided = imguidedfilter(Inuts);       %エッジ保存型の平滑化
imshow([Inuts Iave Iguided]);truesize;shg;

%%
% Copyright 2014 The MathWorks, Inc.

