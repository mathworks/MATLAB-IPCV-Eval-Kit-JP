clear all;clc;close all;imtool close all

%% 画像の取込み･表示
I = imread('coins.png');
figure; imshow(I);

%% 自作ユーザーインターフェースの起動
h = thresholding(I);    % 起動時に、画像データIを渡す
uiwait(h)

%% 出力画像の表示
figure; imshow(OUT);

%% GUIDEの起動（ツール概要説明）
guide

%% 自作GUIを開く
guide thresholding

%%
% Copyright 2014 The MathWorks, Inc.
