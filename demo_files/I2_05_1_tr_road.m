%% 幾何学的変換
clear, clc, close all, imtool close all

%% 画像の読込･表示
I = imread('I2_05_1_ExpTrf.jpg');    % 変数宣言不要、多次元配列
imtool(I)                            % GUI ツール（他にも多々）

%% 変換後の表示領域 (257 x 211)
figure;imshow(ones(257,211));

%% 写像の基準となる4点を設定して空間変換(射影変換)構造体を作成
Porig = [235 424; 483 424; 727 533; 130 533];   % [X,Y] 左上の点から時計回り
Ppost = [1 1; 211 1; 211 257; 1 257];    % 縦256、横210                   % Ppost = bbox2points([1, 1, 210, 256])   でも可
T = fitgeotrans(Porig, Ppost,'projective');                               % projective2d クラス（変換行列と次元）
T.T             % 生成された行列の確認

%% 幾何学的変換後、結果を表示
%    imref2d:出力画像領域をWorld座標系で指定 sizeの出力と同じフォーマット：[縦 横]
Iw = imwarp(I, T, 'OutputView', imref2d([257 211]));              % OutputViewを指定しないと、画像の存在するBoundingBoxの左上が原点
imshow(Iw);shg;                                                   % デフォルトは線形補間

%%
% Copyright 2014 The MathWorks, Inc.


%%
G = rgb2gray(Iw);
imageSegmenter(G);

colorThresholder;    % I5_02_cars\DSC_3078a.JPG    青信号
I = imread('I5_03_1_ocr\IMG_2521_sign40.JPG');
G = rgb2gray(I);
imtool(G);
imageSegmenter;
imageRegionAnalyzer;
