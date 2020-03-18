%% SLIC スーパーピクセルを用いたセグメンテーション(領域分割)
% SLIC：simple linear iterative clustering
clc;clear;close all;imtool close all;rng('default');

%% 画像の読込み・表示・L*a*b*色空間への変換
I = imread('lighthouse.png');
figure; imshow(I);
Ilab = rgb2lab(I);     % 均等色空間

%% スーパーピクセルを用い小領域に分割
%    目標：できるだけ同じサイズの、600個の類似色領域になるように分割
[Ls, N] = superpixels(Ilab, 600, 'IsInputLab',true);     % デフォルトでは内部でL*a*b*へ変換
N                             % N :結果的に生成されたスーパーピクセル数
imtool(Ls, []);               % Ls:画素値を見て、ラベル画像になっているのを確認   

%% スーパーピクセルの表示
Bmask = boundarymask(Ls);             % ラベル境界をトレース（2値画像）
I1 = imoverlay(I, Bmask,'cyan');      % 画像中に、2値画像を指定色で上書き
figure;imshow(I1); shg;

%% スーパーピクセル毎に平均値を算出し、その領域の色を置換え･表示
pixIdxList = label2idx(Ls);    % 各ラベル領域の行列インデックスを取得
sz = numel(Ls);                % 画素数
for  i = 1:N    % 各スーパーピクセル毎に計算
  superLab(i,1) = mean(Ilab(pixIdxList{i}      ));  % L*成分平均値
  superLab(i,2) = mean(Ilab(pixIdxList{i}+   sz));  % a*成分平均値
  superLab(i,3) = mean(Ilab(pixIdxList{i}+ 2*sz));  % b*成分平均値
end
I2 = label2rgb(Ls, lab2rgb(superLab));
figure; imshowpair(I, imoverlay(I2, boundarymask(Ls),'cyan'), 'montage'); truesize;

%% K-meansでさらに、色の類似度を用いクラスタリング
numColors = 3;  % 3つに分類
Lc = imsegkmeans(I2,numColors,'NormalizeInput',false);
I3  = label2rgb(Lc); % ラベル画像をRGB画像に変換
% 画像中に、2値画像を指定色で上書き
imshow(I3); shg;

%% 灯台部分を抽出
% 画像端に接している領域を除去（ラベル毎に処理）
Lm = imclearborder(Lc==1);
for i = 2:numColors
  Lm = [Lm imclearborder(Lc==i)];
end
% 面積の大きい上位2つの領域を抽出
maskA  = bwareafilt(Lm, 2);
% マスクの生成･結果の表示
maskA1 = reshape(maskA, [size(Ls), numColors]);
maskA2 = sum(maskA1, 3);
maskA3 = imfill(maskA2, 'holes');       % マスクの穴を埋める
Iout = imoverlay(I, ~maskA3, 'green');
figure; imshow(Iout);                   % 表示

%% Copyright 2018 The MathWorks, Inc.
