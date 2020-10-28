%% ハイパースペクトル画像の表示
clc;clear;close all;imtool close all;rng('default');

%% 画像の読込み・表示
hcube = hypercube('paviaU.hdr');
% 表示用にRGBバンドを抽出
img = colorize(hcube, 'Method','rgb','ContrastStretching',true);
imshow(img);

%% Copyright 2020 The MathWorks, Inc.
