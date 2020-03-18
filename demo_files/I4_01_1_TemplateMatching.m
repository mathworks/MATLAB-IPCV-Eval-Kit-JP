clear;clc;close all;imtool close all

%% テンプレートマッチング用のオブジェクト作成
htm=vision.TemplateMatcher;

%% 画像の取込み・グレースケール化
I = im2double(imread('board.tif'));
I = I(1:200,1:200,:);      % 画像が大きいので一部切り出す
Igray = rgb2gray(I);
figure;imshow(Igray);

%% テンプレート画像の生成・表示
T = Igray(20:75,90:135);
figure; imshow(T);

%% テンプレートマッチングの実行
Loc = step(htm, Igray, T)            % テンプレート中心に対応する座標 [x y]

%% 見つかった場所にマーキング・結果画像の表示
J = insertShape(I, 'FilledCircle', [Loc, 10], 'Opacity', 1, 'Color', 'red');
figure; imshow(J); title('Marked target');

%% 終了
% Copyright 2014 The MathWorks, Inc.











%% Metric matrix の取得
release(htm);
htm=vision.TemplateMatcher('OutputValue','Metric matrix', 'OverflowAction','Saturate');    % 画像がuint8の為、内部は固定小数点モード
mat = step(htm,Igray,T);
imtool(mat);

%% テンプレートを転置し、合うものがない場合
T1 = T';
figure; imshow(T1);
%% テンプレートマッチングの実行
release(htm);
htm=vision.TemplateMatcher('BestMatchNeighborhoodOutputPort',true, 'NeighborhoodSize',1);
[Loc val] =step(htm, Igray, T)

