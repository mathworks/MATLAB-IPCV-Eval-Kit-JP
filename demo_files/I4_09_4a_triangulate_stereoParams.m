%% 顔までの距離の測定
%    ステレオパラメータ、左右の画像の対応点が既知の場合
clc;clear;close all;imtool close all;

%%  ステレオカメラパラメータの読込み
load('webcamsSceneReconstruction.mat');

%% 左右のカメラの画像を読込み･表示
I1 = imread('sceneReconstructionLeft.jpg');
I2 = imread('sceneReconstructionRight.jpg');
figure; imshowpair(I1, I2, 'montage'); truesize;

%% レンズ歪の除去
I1u = undistortImage(I1, stereoParams.CameraParameters1);     % デフォルト設定ではnewOrigin=[0 0], i.e., 中心は不変
I2u = undistortImage(I2, stereoParams.CameraParameters2);     % デフォルト設定ではnewOrigin=[0 0], i.e., 中心は不変
figure; imshowpair(I1u, I2u, 'montage'); truesize;

%% 両方の画像から、正面を向いている顔の検出・表示
faceDetector = vision.CascadeObjectDetector;
face1 = step(faceDetector,I1u)           % (x0, y0, 幅, 高さ)
face2 = step(faceDetector,I2u)
I1i = insertShape(I1u,'Rectangle',face1, 'LineWidth', 5);
I2i = insertShape(I2u,'Rectangle',face2, 'LineWidth', 5);
imshowpair(I1i, I2i, 'montage'); shg;

%% 顔の中心点座標の計算
center1 = face1(1:2) + face1(3:4)/2
center2 = face2(1:2) + face2(3:4)/2

%% カメラ１の光学中心から、顔の中心のX･Y･Z方向の距離を計算 (mm単位)
point3d = triangulate(center1, center2, stereoParams)

%% メートル単位の直線距離へ変換
distanceInMeters = norm(point3d)/1000

%% Copyright 2015 The MathWorks, Inc.
