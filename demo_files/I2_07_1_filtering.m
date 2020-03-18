%% 事前定義型フィルタ（fspecial関数）
clear;clc;close all;imtool close all

%% 画像の読込み
I = imread('cameraman.tif');
figure;subplot(2,2,1);imshow(I);title('Original Image'); 

%% average filter
F = fspecial('average',5)
ImagAve = imfilter(I,F);
subplot(2,2,2);imshow(ImagAve);title('平均化フィルタ');shg;
%% laplacian filter (二次微分)
F = fspecial('laplacian')
ImagSob = imfilter(I,F);
subplot(2,2,3);imshow(ImagSob);title('ラプラシアンフィルタ');shg;
%% motion filter
F = fspecial('motion',20,45)
ImagMotion = imfilter(I,F);
subplot(2,2,4);imshow(ImagMotion);title('モーションフィルタ');shg;

%% 終了









%% 先鋭化
ImagSharpen = imsharpen(I);
figure;imshowpair(I, ImagSharpen, 'montage');
%% gaussian filter
F = fspecial('gaussian', [5 5], 3)
ImagSharp = imfilter(I,F);
figure;imshow(ImagSharp);title('ガウシアンフィルタ');
%% disk filter
F = fspecial('disk',10)
ImagSharp = imfilter(I,F,'replicate');
figure;imshow(ImagSharp);title('円状平均化フィルタ');
%% log filter
F = fspecial('log')
ImagLog = imfilter(I,F);
figure;imshow(ImagLog);title('ガウスのラプラシアン フィルタ');

%% 
% Copyright 2014 The MathWorks, Inc.




