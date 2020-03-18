%% エッジ保存平滑化フィルタ(違法性拡散フィルタ、バイラテラルフィルタ)
%  画像読み出し
I = imread('cameraman.tif');
imshow(I)
title('Original Image')
%% 異方性拡散フィルタの適用
Idiffusion = imdiffusefilt(I);
%% バイラテラルフィルタの適用
% 一部分を切り出し、ノイズレベルを評価
patch = imcrop(I,[170, 35, 50 50]);
patchVar = std2(patch)^2; 
% ノイズの分散レベルより大きい値をスムージングのレベルとしてセットし、バイラテラルフィルタを適用
DoS = 2*patchVar;
J = imbilatfilt(I,DoS);

%% ガウスフィルタの適用
sigma = 1.2;
Igaussian = imgaussfilt(I,sigma);

%% 各フィルタ処理結果の比較
montage({I,Idiffusion,J,Igaussian},'ThumbnailSize',[])
title('違法性拡散フィルタ(右上) vs. バイラテラルフィルタ(左下) vs.ガウシアンフィルタ(右下)')
% 左上が元画像
% 違法性拡散フィルタやバイラテラルフィルタは
% ガウシアンフィルタよりエッジがシャープに保持される

%% 
% Copyright 2018 The MathWorks, Inc.