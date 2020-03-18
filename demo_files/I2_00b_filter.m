clear all; close all; clc;

%% 画像の取り込み
I=imread('cameraman.tif');
figure; imshow(I);

%% 平均化フィルター処理
Fave=fspecial('average');           % フィルター係数生成
Iave=imfilter(I, Fave);             % フィルター処理
I=[I Iave];                         % 右横に別の画像を拡張
figure; imshow(I);                  % 表示

%% 鮮明化処理
Ish=imsharpen(Iave, 'Amount', 3);      % フィルター処理、強度
figure; imshowpair(Iave, Ish, 'montage');% 横並び可視化

fspecial('average')
fspecial('average', 5)
edit fspecial      % fspecial関数の実装表示 or 関数選んでF4




%% 終了






%% 初期化
clear all; close all; clc;

%% 中間値フィルターによる、ノイズ除去
I = imread('peppers_noise.png');   % 画像読込、名前をI
figure; imshow(I);                 % 表示
%%
Imedian = medfilt2(I, [3 3]);     % ノイズ除去
figure; imshow(Imedian);          % 表示
%% 終了






% [fspecial関数の実装の補足]
%
% 例えば  fspecial('average',5) の場合 ==> type='average, p2=[5 5] となる
%
% <実装>
% switch type
%  case 'average'               % Smoothing filter
%     siz = p2;                     % [5 5]
%     h   = ones(siz)/prod(siz);    % "全ての要素が1の5行5列の行列" / 要素の積 (5*5=25)


%% (参考)  'peppers_noise.png' の生成法
%N = rgb2gray(imread('peppers.png'));
%N = imnoise(N, 'salt', 0.1);           %ごま塩ノイズを加える
%imwrite(N, 'peppers_noise.png');


% Copyright 2014 The MathWorks, Inc.
