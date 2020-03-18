%% GPU処理 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 初期設定
clc;close all;imtool close all;clear all;
g=gpuDevice,reset(g);                   % GPUデバイスへのオブジェクトを取得
a=imrotate(gpuArray(uint8(0)),1);       % GPU用関数のメモリーへの読込み

%% 画像の読込み・表示
I = imread('saturn.png');
I1 = rgb2gray(repmat(I, 6,6));   % 縦横 各６倍のサイズへ
figure;imshow(I1);

%% CPU 上での処理時間の計測・表示
tic;
  I2 = imrotate(I1, 37, 'loose', 'bilinear');    % 大きな画像を37°回転
t1 = toc

%% 結果の表示
figure;imshow(I2);

%% GPUへデータをコピー
Ig1=gpuArray(I1);

%% GPU 上での処理時間の計測
tic;
  Ig2 = imrotate(Ig1, 37, 'loose', 'bilinear');   % 大きな画像を37°回転
  wait(g)                                         % 必ず、toc()を呼び出す前に、すべての処理が完了するのを待つ
t2 = toc

%% 比率を計算
t1/t2

%% GPU デバイスをリセットし、そのメモリを消去する
reset(g)


%% Copyright 2014 The MathWorks, Inc.

