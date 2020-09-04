%% *2.1.4 グラフィックス (マーカー描画・テキスト描画・図形描画)*
%% 概要
% MATLABで画像にマーカーや注釈、図形、テキストを描画・挿入する方法を紹介します。
% 
% Computer Vision Toolbox?の各種描画関数を活用します。
%% 初期化

clear; clc; close all; imtool close all
%% 画像を読み込む

I = imread('visionteam1.jpg');
figure; imshow(I);
%% 人物検出のアルゴリズムを実行
% 可視化に使用するために人物検出器を使ってバウンディングボックスの座標とスコアを計算します。

detector = peopleDetectorACF;
[bboxes,scores] = detect(detector,I)
%% 検出したバウンディングボックスを描画
% はじめに検出したバウンディングボックスを描画します。

Iboxes = insertShape(I,'rectangle',bboxes);
imshow(Iboxes)
%% 
% バウンディングボックスの枠の太さや色を変えてみます。

Iboxes = insertShape(I,'rectangle',bboxes,"LineWidth",5,"Color","red");
imshow(Iboxes)
%% 検出したバウンディングボックスを描画(キャプションを追加)
% 次に各検出結果のスコアをキャプションとしてバウンディングボックスを可視化します。

Iout = insertObjectAnnotation(I,'rectangle',bboxes,scores);
figure
imshow(Iout)
%% 
% 高いスコアと低いスコアで異なる色になるようにします。

% カラーマップを生成
cmap = jet;

% スコアを0-255に正規化
scoreNorm = im2uint8(mat2gray(scores));

% カラーマップに割り当て
colors = im2uint8(reshape(ind2rgb(scoreNorm,cmap),[],3));

% バウンディングボックスを挿入した画像生成
Iout = insertObjectAnnotation(I,'rectangle',bboxes,scores,...
    "LineWidth",3,"Color",colors);
figure
imshow(Iout)
%% テキスト挿入
% テキストを挿入します。日本語で挿入することも可能です。

listTrueTypeFonts % フォントのリスト確認
Iout2 = insertText(Iout,[1,1],'人物検出結果の可視化',...
    'Font','MS UI Gothic','FontSize',25,...
    'BoxColor','blue','TextColor','white');
figure, imshow(Iout2);
%% マーカー挿入
% マーカーを描画・挿入します。
% 
% 例として検出された人物上でORB特徴を抽出し、その特徴点を描画します。

points = detectORBFeatures(rgb2gray(I),'ROI',bboxes(3,:));

% スコアを0-255に正規化
metricNorm = im2uint8(mat2gray(points.Metric));

% カラーマップに割り当て
colors = im2uint8(reshape(ind2rgb(metricNorm,parula),[],3));

% 描画
Iout3 = insertMarker(Iout2,points.Location,"plus","Color",colors);
figure, imshow(Iout3);
%% 図形挿入
% 任意の図形を挿入することもできます。

% 特徴点の重複を取り除く
loc = unique(double(points.Location),'rows');
% 三角形分割
DT = delaunayTriangulation(loc(:,1),loc(:,2));
%凸包を計算
C = convexHull(DT);
% [x1,y1,x2,y2,...]というベクトルに変換
polyPos = reshape([DT.Points(C,1),DT.Points(C,2)]',1,[]);
% ポリゴンとして挿入
Iout4 = insertShape(Iout3,'Polygon',polyPos,'LineWidth',5);

% 顔検出
faceDetector = vision.CascadeObjectDetector();
bboxesFace = faceDetector(rgb2gray(I));
% 円を描画するために[x,y,r]のベクトルに変換
posCir = [bboxesFace(:,1:2)+bboxesFace(:,3:4)/2 bboxesFace(:,3)/2];
Iout5 = insertShape(Iout4,'Circle',posCir,'LineWidth',5);

figure, imshow(Iout5);
%% まとめ
% MATLABで画像にマーカーや注釈、図形、テキストを描画・挿入する方法を紹介しました。
% 
% 画像処理、コンピュータービジョン、ディープラーニングなどの処理結果の可視化にお役立てください。
%% 参考
%% 
% * <https://jp.mathworks.com/help/vision/ref/inserttext.html |insertText|>
% * <https://jp.mathworks.com/help/vision/ref/insertobjectannotation.html |insertObjectAnnotation|>
% * <https://jp.mathworks.com/help/vision/ref/insertshape.html |insertShape|>
% * <https://jp.mathworks.com/help/vision/ref/insertmarker.html |insertMarker|>
%% 
% Copyright 2020 The MathWorks, Inc.
% 
%