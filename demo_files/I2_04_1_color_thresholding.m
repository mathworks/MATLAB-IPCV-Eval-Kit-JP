clc;close all;imtool close all;clear;

%% 静止画像の読込み・表示
A=imread('peppers.png');
figure;imshow(A);

%% 色の閾値アプリケーションを起動(下記コマンドもしくは、アプリケーション タブから起動)
colorThresholder(A)    % 色の閾値 アプリケーション：紫のテーブルクロスのみ除去

% Copyright 2014 The MathWorks, Inc.
