%% ステレオ平行化 (Stereo Image Rectification)
%    SURF特徴点によるマッチング
%    estimateFundamentalMatrix()         : 基礎行列を求める
%    estimateUncalibratedRectification() : ステレオ平行化のための射影変換行列を求める

clear all;clc;close all;imtool close all
%% Step 1: 左右の画像の読込・グレースケール化、表示
I1 = rgb2gray(imread('yellowstone_left.png'));
I2 = rgb2gray(imread('yellowstone_right.png'));
figure; imshowpair(I1, I2,'montage');truesize; % 左右に並べて表示
      % 右の絵は下がっている・左にずれています
%% 重ねて表示
figure;imshow(stereoAnaglyph(I1, I2));truesize;
      
%% Step 2: 特徴点の検出
blobs1 = detectSURFFeatures(I1, 'MetricThreshold', 2000);
blobs2 = detectSURFFeatures(I2, 'MetricThreshold', 2000);

%% Step 3: 特徴量の抽出･表示
[features1, validBlobs1] = extractFeatures(I1, blobs1);
[features2, validBlobs2] = extractFeatures(I2, blobs2);
figure; imshow(I1); hold on; plot(validBlobs1.selectStrongest(30),'showOrientation',true);
figure; imshow(I2); hold on; plot(validBlobs2.selectStrongest(30),'showOrientation',true);

%% Step 4: 左右の特徴点のマッチングをし対応点を求める・表示
indexPairs = matchFeatures(features1, features2, 'Metric', 'SAD', ...
  'MatchThreshold', 5);

matchedPoints1 = validBlobs1(indexPairs(:,1),:);
matchedPoints2 = validBlobs2(indexPairs(:,2),:);
figure; showMatchedFeatures(I1, I2, matchedPoints1, matchedPoints2);
legend('Points in I1', 'Points in I2');

%% Step 5: 基礎行列（左右の画像の位置関係）を求める (outlier除去も)
[fMatrix, epipolarInliers, status] = estimateFundamentalMatrix(...
  matchedPoints1, matchedPoints2, 'Method', 'RANSAC', ...
  'NumTrials', 10000, 'DistanceThreshold', 0.1, 'Confidence', 99.99);
fMatrix            % 3x3の行列の表示

% エラーチェック
if status ~= 0 || isEpipoleInImage(fMatrix, size(I1)) ...
  || isEpipoleInImage(fMatrix', size(I2))
  error(['Either not enough matching points were found or '...
         'the epipoles are inside the images. You may need to '...
         'inspect and improve the quality of detected features ',...
         'and/or improve the quality of your images.']);
end

% matchedPoints から、Inlierのもののみ抜き出す
inlierPoints1 = matchedPoints1(epipolarInliers);
inlierPoints2 = matchedPoints2(epipolarInliers);

%% Step 5: ステレオ平行化・特徴点の重なり具合の表示
%     (左右の画像それぞれの射影変換行列を求める)
[t1, t2] = estimateUncalibratedRectification(fMatrix, ...
  inlierPoints1.Location, inlierPoints2.Location, size(I2));
tform1 = projective2d(t1);    %射影変換行列を幾何学変換クラスへ
tform2 = projective2d(t2);

% 左右の画像を幾何学変換後、出力する領域をWorld座標系で指定
I1Rect = imwarp(I1, tform1, 'OutputView', imref2d(size(I1)));
I2Rect = imwarp(I2, tform2, 'OutputView', imref2d(size(I2)));

% マッチング確認のため、特徴点も幾何学変換し、マッチング表示
%    ずれは、横方向のみ （エピポーラ線はX軸と平行）
pts1Rect = transformPointsForward(tform1, inlierPoints1.Location);
pts2Rect = transformPointsForward(tform2, inlierPoints2.Location);

figure; showMatchedFeatures(I1Rect, I2Rect, pts1Rect, pts2Rect);
legend('Inlier points in rectified I1', 'Inlier points in rectified I2');

%% 重なっている部分のみ切出し
%    赤-シアンのステレオメガネで、3D画像を観察
Irectified = cvexTransformImagePair(I1, tform1, I2, tform2);
figure, imshow(Irectified);truesize;
title('Rectified Stereo Images (Red - Left Image, Cyan - Right Image)');

%% 終了






%% Disparityマップの計算
d = disparity(Irectified(:,:,1), Irectified(:,:,2), 'BlockSize', 21,'DisparityRange', [-6 10], 'UniquenessThreshold', 0);

% -realmax('single') と、振り切れてしまったPixelの値を、
% それ以外のpixelの最小値に置き換える
marker_idx = (d == -realmax('single'));
d(marker_idx) = min(d(~marker_idx));

% Disparityマップの表示。カメラに近い画素を、明るく表示。
figure; imshow(mat2gray(d));

%% 表面プロットを使い表示
figure; surf(mat2gray(d));shading interp;xlabel('X');ylabel('Y');axis ij

%% 

%figure;imshowpair(I1Rect, I2Rect, 'montage');truesize;
%figure;imshow(cat(3,I1Rect, I2Rect, I2Rect));truesize; %重なっていないところも表示した場合



%  Copyright 2004-2014 The MathWorks, Inc.

