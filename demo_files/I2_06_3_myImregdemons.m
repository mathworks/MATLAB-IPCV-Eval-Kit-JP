%% 非剛体のレジストレーション (2次元・3次元のグレースケール画像)
clear;clc;close all;imtool close all;

%% ２つの画像の読込み
fixed  = imread('hands1.jpg');      % 位置合せのターゲット
moving = imread('I2_06_3_hands2a.jpg');
figure;imshow([fixed, moving]);

%% グレースケールへ変換･重ねて表示
fixed  = rgb2gray(fixed);
moving = rgb2gray(moving);
figure;imshowpair(fixed,moving);

%% グレースケールを並べて表示
figure;subplot(2,1,1); imshow([fixed, moving]);

%% [前処理] ヒストグラムマッチングを用いて、輝度の差を補正
moving = imhistmatch(moving,fixed);
subplot(2,1,2); imshow([fixed, moving]);

%% 変位場行列を求める  （fixed上の各ピクセル毎の、X,Y方向の変位）
D = imregdemons(moving, fixed, [500 400 200]);    %反復回数：500回(低解像度), 400回, 300回(高解像度)

%% 変位の可視化
flow = opticalFlow(D(:,:,1), D(:,:,2));
figure;imshow(fixed);
hold on
plot(flow,'DecimationFactor',[10 10],'ScaleFactor',1); shg;
hold off

%% 幾何学的変換・表示
movingReg = imwarp(moving, D);
figure;imshow([moving, movingReg]);
title('幾何学的変換の前後', 'FontSize', 16);

%% 位置合せのターゲット画像と重ねて表示
figure;imshowpair(fixed, movingReg);

%% 終了
















%% シンプルな図形での処理
fixed = zeros(100);
moving = fixed;
fixed(50:59, 30:39)=1;
fixed(50:59, 55:64)=1;
moving(50:59, 30:39)=1;
moving(50:59, 45:54)=1;        % 右に10ピクセル移動

figure; subplot(1,2,1); imshow(fixed);
        subplot(1,2,2); imshow(moving); shg;
figure;imshowpair(fixed, moving);        
%
D = imregdemons(moving, fixed, [500 400 200], 'AccumulatedFieldSmoothing',0.5);    %反復回数：500回(低解像度), 400回, 300回(高解像度)
% 幾何学的変換・表示
movingReg = imwarp(moving, D);
imtool(movingReg);
figure;imshowpair(fixed, movingReg);    % ほぼ一致している

%% 変位場の可視化
flow = opticalFlow(D(:,:,1), D(:,:,2));
figure;imshow(moving);
hold on
plot(flow,'DecimationFactor',[5 5],'ScaleFactor',1); shg;
hold off
%% 変位場の値の確認
D(55, 30:69, 1)          % Dの値：fixedの対応する点の移動

%% 参考：hands2a.jpg の生成スクリプト
I = imread('hands2.jpg');
ycbcr = rgb2ycbcr(I);
ycbcr(:,:,1) = ycbcr(:,:,1)*0.8;
I1 = ycbcr2rgb(ycbcr);
imwrite(I1, 'I2_06_2_hands2a.jpg');

%% Copyright 2014 The MathWorks, Inc.
