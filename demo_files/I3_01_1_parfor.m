clear all;clc;close all;imtool close all

%% 画像の読込み･輝度と色差成分の分離
I = imread('saturn.png');
figure; imshow(I);

%% 輝度に対してDCTを計算
YCbCr = rgb2ycbcr(I);      % YCbCr色空間へ変換
fun = @(block_struct) dct2(block_struct.data);  % 無名関数のハンドル定義
tic;
DCTy = blockproc(YCbCr(:,:,1), [8 8],fun);
t0=toc
imtool(log(abs(DCTy)+1),[]);                     % 対数表示

%% 2次元離散コサイン変換 (Y成分とCb成分)
tic;
for i = 1:2
  DCTycb(:,:,i) = blockproc(YCbCr(:,:,i), [8 8],fun);
end
t1=toc

%% 並列計算用の MATLAB セッションのプールを開く
parpool

%% 並列処理で高速化
tic;
parfor i = 1:2
  DCT(:,:,i) = blockproc(YCbCr(:,:,i), [8 8],fun);
end
t2=toc

%% 並列化による高速化割合の計算（2回目以降で確認）
t2/t1

%% 並列計算用の MATLAB セッションのプールを閉じる
delete(gcp('nocreate'))

%% 


% Copyright 2018 The MathWorks, Inc.