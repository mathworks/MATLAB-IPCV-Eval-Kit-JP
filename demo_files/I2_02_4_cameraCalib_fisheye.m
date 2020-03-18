%% 魚眼レンズで撮影した画像の歪補正
clear;clc;close all;imtool close all

%% カメラキャリブレーション用の画像の確認
imageFolder = [toolboxdir('vision'),'\visiondata\calibration\gopro'];
winopen(imageFolder);

%% アプリケーションによる魚眼レンズ歪推定(R2018a)
squareSize = 29;      % 升目一つのサイズ（単位：mm）
cameraCalibrator(imageFolder,squareSize);
% カメラモデルを「魚眼」に設定して「キャリブレーション」を実行

%% カメラパラメータ推定用の、キャリブレーションパターンの画像指定
images = imageDatastore(imageFolder);
figure; montage(images.Files)

%% 画像内のチェッカーボードのパターンの検出
[imagePoints, boardSize] = detectCheckerboardPoints(images.Files);

%% コーナー点の 実世界での位置(world coordinates) を計算：最初のコーナー=(0,0)
squareSize = 29;      % 升目一つのサイズ（単位：mm）
worldPoints = generateCheckerboardPoints(boardSize, squareSize);

%% カメラパラメータの推定
I = readimage(images,1); imageSize = [size(I,1),size(I,2)];  % 画像サイズの取得
params = estimateFisheyeParameters(imagePoints, worldPoints, imageSize);

%% 推定した外部パラメータの可視化
figure; showExtrinsics(params);

%% 歪補正・結果の表示
J1 = undistortFisheyeImage(I, params.Intrinsics,'OutputView','full');
figure; imshowpair(I,J1,'montage'); truesize;

%% 結果の表示（周囲の除去し、元の画像と同サイズへ）
J2 = undistortFisheyeImage(I,params.Intrinsics);
figure; imshowpair(I,J2,'montage'); truesize;

%%
% Copyright 2014 The MathWorks, Inc.
