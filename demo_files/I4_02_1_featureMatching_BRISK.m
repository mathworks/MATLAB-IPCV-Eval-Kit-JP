%% 特徴点を用いた物体の検出
clc;clear;close all;imtool close all;

%% 検索する物体の画像の読込み･表示
Iref = imread('I4_02_1_p1a.jpg');
figure; imshow(Iref);

%% 非検索画像の読込み･表示
I = imread('I4_02_1_p2a.jpg');
figure;imshow(I);

%% それぞれの画像で、特徴点検出・表示
Gref = rgb2gray(Iref);        % グレースケールへ変換
G    = rgb2gray(I   );

PointsRef = detectBRISKFeatures(Gref);  % 特徴点の検出
PointsI   = detectBRISKFeatures(G);

subplot(1,2,1); imshow(Iref); hold on;
plot(PointsRef.selectStrongest(100));     % 上位100ポイントをプロット
subplot(1,2,2); imshow(I   ); hold on;
plot(PointsI.selectStrongest(100)); hold off; shg;

%% 特徴量(Feature, ValidPoints)抽出、表示
[FeaturesRef, vPointsRef] = extractFeatures(Gref, PointsRef, 'Method', 'BRISK');
[FeaturesI,   vPointsI  ] = extractFeatures(G,    PointsI,   'Method', 'BRISK');

subplot(1,2,1); imshow(Iref); hold on;
plot(vPointsRef.selectStrongest(100),'showOrientation',true);
subplot(1,2,2); imshow(I); hold on;
plot(vPointsI.selectStrongest(100),'showOrientation',true);hold off;shg;

%% 特徴量(FeaturesRef,FeaturesI)のマッチング・結果表示   (一部 outlier が存在)
indexPairs = matchFeatures(FeaturesRef, FeaturesI, 'MatchThreshold',30, 'MaxRatio',0.8);

matchedPointsRef = vPointsRef(indexPairs(:, 1));  % Iref上の位置取出
matchedPointsI   = vPointsI(  indexPairs(:, 2));  % I上の位置取出
figure;
showMatchedFeatures(Iref, I, matchedPointsRef, matchedPointsI, 'montage'); truesize;

%% 変換行列の推定(MSAC)と、誤対応点の除去、正対応点の表示
[tform, inlierIndex] = ...
    estimateGeometricTransform2D(matchedPointsRef, matchedPointsI, 'projective', 'MaxDistance', 3);

inlierPointsRef = matchedPointsRef.Location(inlierIndex,:);
inlierPointsI   = matchedPointsI.Location(inlierIndex,:);

figure; showMatchedFeatures(Iref, I, inlierPointsRef, inlierPointsI, 'montage');


%% 得られた変換行列の表示
tform.T

%% 得られた行列で領域を変換し、検出した部分を線で囲む
PolygonRef = bbox2points([1 1 size(Iref, 2) size(Iref, 1)]);   %元画像の四隅
newPolygonRef = transformPointsForward(tform, PolygonRef);    %変換後の四隅

foundObj = insertShape(I, 'Polygon', reshape(newPolygonRef',[1 8]), 'Color','red', 'LineWidth',10);
figure; imshow(foundObj);

%% 終了
% % Copyright 2020 The MathWorks, Inc.
