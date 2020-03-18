%% 顔までの距離の測定
clc;clear;close all;imtool close all;

%% カメラ1・2の、内部・外部(並進・回転)パラメータの読込み
load('I4_09_4b_params.mat');

%% カメラ1・2の、カメラ行列（ワールド座標と画像上ピクセル座標の関係）の計算
camMatrix1 = cameraMatrix(cameraParams1, cam1R, cam1T);
camMatrix2 = cameraMatrix(cameraParams2, cam2R, cam2T);

%% 左右のカメラの画像を読込み･表示
I1 = imread('sceneReconstructionLeft.jpg');
I2 = imread('sceneReconstructionRight.jpg');
figure; imshowpair(I1, I2, 'montage'); truesize;

%% レンズ歪の除去
I1u = undistortImage(I1, cameraParams1);
I2u = undistortImage(I2, cameraParams2);
figure; imshowpair(I1u, I2u, 'montage'); truesize;

%% 両方の画像から、正面を向いている顔の検出・表示
faceDetector = vision.CascadeObjectDetector;
face1 = step(faceDetector,I1)           % (x0, y0, 幅, 高さ)
face2 = step(faceDetector,I2)
I1i = insertShape(I1u,'Rectangle',face1, 'LineWidth', 5);
I2i = insertShape(I2u,'Rectangle',face2, 'LineWidth', 5);
imshowpair(I1i, I2i, 'montage'); shg;

%% 顔の中心点座標の計算
center1 = face1(1:2) + face1(3:4)/2
center2 = face2(1:2) + face2(3:4)/2

%% 外部パラメータで用いたワールド座標原点から、
%              顔の中心への距離を計算 (mm単位)： X・Y・Z
point3d = triangulate(center1, center2, camMatrix1, camMatrix2)

%% カメラ1の光学中心のワールド座標値
x0 = -1 * cam1T * cam1R'

%% カメラ1の光学中心から、顔の中心への距離を計算 (mm単位)： X・Y・Z
point3d = point3d - x0

%% メートル単位の直線距離へ変換
distanceInMeters = norm(point3d)/1000

%% 終了

















%% (参考)ここで用いたカメラ1・2のカメラ内部・外部パラメータの生成
load('webcamsSceneReconstruction.mat');   % ステレオカメラパラメータの読込み
cameraParams1 = stereoParams.CameraParameters1;
cameraParams2 = stereoParams.CameraParameters2;
cam1T = cameraParams1.TranslationVectors(1,:)
cam2T = stereoParams.CameraParameters2.TranslationVectors(1,:)
cam1R = stereoParams.CameraParameters1.RotationMatrices(:,:,1)
cam2R = stereoParams.CameraParameters2.RotationMatrices(:,:,1)

save('I4_09_4b_params.mat', 'cameraParams1', 'cameraParams2', 'cam1T', 'cam2T', 'cam1R', 'cam2R');


%% カメラ1･2の位置･姿勢の関係から、
%  それぞれのカメラ行列(World座標と画像の座標の関係)を計算する場合
%  （ここではWorld座標の原点を画像1のカメラ位置、カメラの方向をZ軸の正にする）
t1 = [0 0 0];      % カメラ1はWorld座標原点と設定（並進移動なし）
R1 = eye(3);       % カメラ1はWorld座標Z軸の正方向と設定（回転なし）
t2 = stereoParams.TranslationOfCamera2    % L=[-95.6895 1.1788 -6.8476]
R2 = stereoParams.RotationOfCamera2
camMatrix1 = cameraMatrix(stereoParams.CameraParameters1, R1, t1);
camMatrix2 = cameraMatrix(stereoParams.CameraParameters2, R2, t2);

%% Copyright 2015 The MathWorks, Inc.
