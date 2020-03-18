%% フラットフィールドによるシェーディング(影)の補正

%% 画像の読み込み
I = imread('fabric.png');
figure
subplot(2,1,1), imshow(I), title('元画像');
% 照明が不均一で外側が暗い

%% フラットフィールド補正
Iflatfield = imflatfield(I, 20);
subplot(2,1,2), imshow(Iflatfield)
title('平滑化画像, \sigma = 20')

%%
% Copyright 2018 The MathWorks, Inc.
