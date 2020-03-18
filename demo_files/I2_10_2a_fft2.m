%% 2次元の高速フーリエ変換のデモ
clear;clc;close all;imtool close all

%% 256x256のテスト画像の生成
I = zeros(256,256);   % 要素0で[256行,256列]の行列の生成
I(5:24,13:17) = 1;    % 左上に白い領域を作成
figure;imshow(I);

%% 2次元のFFT計算：左上隅がゼロ周波数係数(DC成分)
F = fft2(I);
figure;imshow(log(abs(F)), [-1 5]);colormap(jet); colorbar;    % DC成分が左上隅

%% fftshift関数を用い、ゼロ周波数係数(DC成分)を左上隅から、中心へ移動
%     第一象限と第三象限、第二象限と第四象限を入れ替え
Fs = fftshift(F);
figure;imshow(log(abs(Fs)), [-1 5]);colormap(jet); colorbar;

%% 縦軸を対数表示
figure;surf(log(abs(Fs))); shading interp; axis ij;xlabel('X');ylabel('Y');

%% 終了









%% 縦ゼブラパターン
I = [ones(256,2), zeros(256,2)];  % 横方向4ピクセル周期パターン
I1 = repmat(I,[1,64]);            % 256x256 ピクセルの画像
imtool(I1);
F1 = fft2(I1);
Fs1 = fftshift(F1);
figure;surf(abs(Fs1)); shading interp; axis ij;xlabel('X');ylabel('Y');

%% 縦ゼブラパターン (非2の階乗サイズ)
I2 = repmat(I,[1,20]);            % 256x80 ピクセルの画像
imtool(I2);
F2 = fft2(I2);
Fs2 = fftshift(F2);
figure;surf(abs(Fs2)); shading interp; axis ij;xlabel('X');ylabel('Y');

%% 縦ゼブラパターン (非2の階乗サイズ：FFT時に2の階乗へ)
F3 = fft2(I2, 256, 256);      % 画像データを0埋めで配列サイズを大きくし、256x256の結果を生成
Fs3 = fftshift(F3);
figure;surf(abs(Fs3)); shading interp; axis ij;xlabel('X');ylabel('Y');

%% 縦ゼブラパターン (非2の階乗サイズ：手動で2の階乗サイズへ変更)
I3 = [I2, zeros(256,176)];
imtool(I3);
F3 = fft2(I3);
Fs3 = fftshift(F3);
figure;surf(abs(Fs3)); shading interp; axis ij;xlabel('X');ylabel('Y');

%%
% Copyright 2014 The MathWorks, Inc.


