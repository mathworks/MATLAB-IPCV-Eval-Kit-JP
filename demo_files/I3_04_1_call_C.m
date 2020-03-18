close all; clear all; clc;

%% 外部のCコード（read_raw_main.c）をMEX関数化し、
%    MATLABから呼び出せるようにする
% あらかじめ、  mex -setup   でCコンパイラの設定を行っておく
% edit read_raw.c         % これがラッパーファイル。
                          % 下記ヘッダファイルがインクルードされている
                          %      #include "mex.h"
                          % void mexFunction( を定義し
                          %    その中で外部Cコードを呼び出ししている
mex read_raw.c read_raw_main.c

%% バイナリの RAW画像データ読み込み･表示
%      生成された、read_raw.mexw64 をCallする。
raw = read_raw('I3_04_1_onion_wHeader.raw', 1);
imtool(raw,[])

%% 終了













%% [参考] Column major の Little Endian Rawデータ の生成スクリプト
I = imread('onion.png');
G = rgb2gray(I);
figure;imshow(G);
G16 = im2uint16(G);
figure;imshow(G16);

fid = fopen('I3_04_1_onion_wHeader.raw','w');
fwrite(fid, size(G16,1), 'uint16');    % Hight
fwrite(fid, size(G16,2), 'uint16');    % Width
fwrite(fid, G16, 'uint16');            % image data
fclose(fid);

%% Copyright 2014 The MathWorks, Inc.

