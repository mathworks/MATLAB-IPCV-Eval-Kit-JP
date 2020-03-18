%% 2枚の画像間の、ヒストグラムのマッチング
clear;clc;close all;imtool close all

%% 画像の読込み･表示
Ref = imread('I2_03_3_knee1a.tif');  % 膝のMRIイメージの読込み
  A = imread('I2_03_3_knee1b.tif');
figure;imshow([Ref A]);
  
%% ヒストグラム表示
figure;
subplot(2,2,1);imhist(Ref);title('リファレンス');
subplot(2,2,2);imhist(  A);

%% ヒストグラムのマッチング
B = imhistmatch(A, Ref, 256);  % AのヒストグラムをRefに一致させる
subplot(2,2,4);imhist(B);title('処理結果'); shg;

%% 結果の表示
figure;imshow([Ref repmat(239,[512 20]) B]);

%% 終了

% imshowpairは、デフォルトでは輝度がスケーリングされるので注意









%% (参考) 並べて表示する際に、隙間を空ける場合
figure;imshow([Ref repmat(239,[512 20]) A]); 

%% (参考) knee1a.jpg, knee1b.jpgの作成スクリプト
K1 = dicomread('knee1.dcm');   % read in original 16-bit image
max(K1(:))
Ref = uint8(K1/2);
% build concave bow-shaped curve for darkening Reference image
ramp = [0:255]/255;
ppconcave = spline([0 .1 .50  .72 .87 1],[0 .025 .25 .5 .75 1]);
Ybuf = ppval( ppconcave, ramp);
Lut8bit = uint8( round( 255*Ybuf ) );
% pass image Ref through LUT to darken image
A = intlut(Ref,Lut8bit);
figure;imshow([Ref A]);
% ヒストグラム表示
figure;
subplot(1,2,1);imhist(Ref);
subplot(1,2,2);imhist(  A);
% 書出し
imwrite(Ref, 'knee1a.tif');
imwrite(A, 'knee1b.tif');
%% 終了
% Copyright 2014 The MathWorks, Inc.
