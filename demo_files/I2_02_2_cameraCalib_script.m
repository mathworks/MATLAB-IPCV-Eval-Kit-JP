%% スクリプトでの、カメラキャリブレーション %%%%%%%%%%
%      GUIで行うときは、cameraCalibrator    を使用
clear;clc;close all;imtool close all

%% 画像ファイル名の指定
images = imageDatastore(fullfile(toolboxdir('vision'), 'visiondata', ...
    'calibration', 'mono'));
imFileNames = images.Files;

%% 画像の表示
figure;montage(imFileNames, 'Size', [3 5]);truesize

%% 画像内のチェッカーボードのパターンの検出（不適切な画像は自動的に除去）
[imagePoints, boardSize, imagesUsed] = detectCheckerboardPoints(imFileNames);
imFileNames = imFileNames(imagesUsed);

%% 例として一つ目の画像の結果の表示
J = insertMarker(imread(imFileNames{1}), imagePoints(:,:,1), 'o', 'Color', 'green', 'Size', 8);
figure;imshow(J);
  
%% コーナー点の 実世界での位置(world coordinates) を計算：最初のコーナー=(0,0)
squareSize = 150;  % 升目一つのサイズ（単位：mm）
worldPoints = generateCheckerboardPoints(boardSize, squareSize);   % boardSize:縦横のチェッカー数

%% カメラパラメータの推定
cameraParams = estimateCameraParameters(imagePoints, worldPoints);    % デフォルトの単位は mm

%% キャリブレーション誤差の表示
figure; showReprojectionErrors(cameraParams, 'BarGraph');

%% カメラの外部パラメータの可視化（カメラを固定）カメラの中心が原点
figure; showExtrinsics(cameraParams, 'CameraCentric');

%% カメラの外部パラメータの可視化（チェッカーパターンを固定）チェッカーパターンの端が原点
figure; showExtrinsics(cameraParams, 'patternCentric');


%%
% Copyright 2014 The MathWorks, Inc.
