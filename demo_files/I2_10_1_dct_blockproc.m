clear all;clc;close all;imtool close all

%% 画像の読込み
I = imread('saturn.png');
figure; imshow(I);

%% YCbCr色空間へ変換
YCbCr = rgb2ycbcr(I);
Y = YCbCr(:,:,1);      % ここではYのみDCT変換
imshow(Y);shg

%% 2次元離散コサイン変換
fun = @(block_struct) dct2(block_struct.data);  % 無名関数のハンドル:カッコ内に無名関数の引数。ステートメントは1つのみ可。
DCT = blockproc(Y, [8 8],fun);   % funにブロック構造体を渡す:必要に応じて'BorderSize'を指定
imtool(log(abs(DCT)+1),[]);      % 結果の表示

%% 終了










%% 複数のCPUコアを用いた並列計算オプション（Parallel Computing Toolbox必要）
%  並列計算用の MATLAB セッションのプールを開く
parpool

%% 並列オプション無し
tic;   % 処理時間の測定
DCT = blockproc(Y, [8 8],fun);   % funにブロック構造体を渡す
t1=toc

%% 並列計算オプションをオン
tic;
DCT = blockproc(Y, [8 8],fun, 'UseParallel', true);
t2=toc

%% 実行速度改善の割合を計算
t2/t1

%% 並列計算用の MATLAB セッションのプールを閉じる
delete(gcp('nocreate'))

%% 
% Copyright 2014 The MathWorks, Inc.

