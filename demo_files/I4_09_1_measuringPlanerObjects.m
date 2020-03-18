%% キャリブレーション済み単眼カメラによる,
%        カメラ自己位置･姿勢推定、対象物体の3次元位置推定
%   - ワールド座標と画像座標が既知の複数の点を使用
%   - 対象物体は、ワールド座標系のZ=0上に必要
clc;clear;close all;imtool close all;

%% あらかじめ、使用のカメラでカメラキャリブレーションした結果を読込み
load('I4_09_1_cameraParams.mat');

%% 測定対象の物体の画像を読込み･表示
imOrig = imread([matlabroot '\toolbox\vision\visiondata\calibration\slr\image9.jpg']);
figure; imshow(imOrig);

%% カメラパラメータを用い、レンズ歪を除去 => 求めたいものは画像座標(2455, 1060)
[im, newOrigin] = undistortImage(imOrig, cameraParams);      % デフォルト設定ではnewOrigin=[0 0], i.e., 中心は不変
imtool(im);
imagePoints1 = [2455, 1060]        % 手前のコインの中心座標

%% 外部パラメータを推定
% 画像内のチェッカーボードの交点を検出
[imagePoints, boardSize] = detectCheckerboardPoints(im);
% ワールド座標系での、チェッカーパターンの交点の理想座標を計算
squareSize = 29;      % 29mm
worldPoints = generateCheckerboardPoints(boardSize, squareSize);
% 外部パラメータの推定（レンズ歪の無い画像上の点座標を使用）
[R, t] = extrinsics(imagePoints, worldPoints, cameraParams)

%% カメラの光学中心の、ワールド座標での位置･姿勢を計算
Location    = -t * R'        % [1x3]
Orientation = R'             % [3x3]

%% コインの中心点の、ワールド座標を推定（ワールド座標系Z=0平面上のXY座標）
worldPoints1 = pointsToWorld(cameraParams, R, t, imagePoints1)

%% カメラからコイン中心点までの距離の計算
distanceToCamera = norm([worldPoints1 0] + t*R');

%% 終了















%% [参考] I4_09_1_cameraParams.matの生成
%% カメラキャリブレーション用の画像の準備
numImages = 9;
files = cell(1, numImages);
for i = 1:numImages
    files{i} = fullfile(matlabroot, 'toolbox', 'vision', 'visiondata', ...
        'calibration', 'slr', sprintf('image%d.jpg', i));
end

%% カメラキャリブレーション
% チェッカーボードの画像から、チェッカーの交点を検出
[imagePoints, boardSize] = detectCheckerboardPoints(files);

% チェッカーパターンのワールド座標を生成
squareSize = 29; % 29mm
worldPoints = generateCheckerboardPoints(boardSize, squareSize);

% カメラキャリブレーションの実行
cameraParams = estimateCameraParameters(imagePoints, worldPoints);
save('I4_09_1_cameraParams.mat', 'cameraParams');
  
  
%%   Copyright 2013-2014 The MathWorks, Inc.

