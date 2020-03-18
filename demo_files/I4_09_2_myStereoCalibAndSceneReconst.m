%% Stereo Calibration and Scene Reconstruction 
% 1: ステレオカメラのキャリブレーション
% 2: ステレオ平行化 (Rectification)
% 3: 視差(Disparity)の計算
% 4: Reconstruct the 3-D point cloud
clc;close all;imtool close all;clear;

%% 1: ステレオカメラのキャリブレーション %%%%%%%%%%%%%%%
% ファイル名の指定（左右10枚ずつ）
leftImages = imageDatastore(fullfile(toolboxdir('vision'),'visiondata', ...
    'calibration','stereo','left'));
rightImages = imageDatastore(fullfile(toolboxdir('vision'),'visiondata', ...
    'calibration','stereo','right'));
imageFileNames1 = leftImages.Files;
imageFileNames2 = rightImages.Files;

%% 一枚を例として大きく表示
image1 = imread(imageFileNames1{1});
figure;imshow(image1);

%% 画像の表示: 上段が左画像・下段が右画像
figure;montage([imageFileNames1 imageFileNames2], 'Size', [2 10]);truesize;   

%% 左右の全画像セットから、パターンのコーナー点を検出･一枚目の画像の表示
[imagePoints, boardSize, pairsUsed] = ...
                 detectCheckerboardPoints(imageFileNames1, imageFileNames2);
figure;imshow(insertMarker(image1, imagePoints(:,:,1,1), 'o', 'Color', 'green', 'Size', 5));  %１枚目の左画像

% コーナー点の 実世界での位置(world coordinates) を計算
squareSize = 108; % 単位：mm
worldPoints = generateCheckerboardPoints(boardSize, squareSize);

%% ステレオカメラパラメータの推定(Apps)
[leftFolder,~,~] = fileparts(leftImages.Files{1});
[rightFolder,~,~] = fileparts(rightImages.Files{1});
stereoCameraCalibrator(leftFolder,rightFolder,squareSize);

%% ステレオカメラパラメータの推定
stereoParams = estimateCameraParameters(imagePoints, worldPoints);

%% キャリブレーション誤差の表示
figure; showReprojectionErrors(stereoParams);

%% カメラの外部パラメータの可視化（カメラを固定）
figure; showExtrinsics(stereoParams);

%% カメラの外部パラメータの可視化（チェッカーパターンを固定）
figure; showExtrinsics(stereoParams, 'patternCentric');
 
%% 2: ステレオ平行化 (Rectification) %%%%%%%%%%%%%%%%%%%%%%
% 左右ペアの画像を読込み・表示
I1 = imread(imageFileNames1{1});
I2 = imread(imageFileNames2{1});
figure;imshowpair(I1, I2, 'montage');
%% 重ねて表示
figure; imshow(stereoAnaglyph(I1, I2), 'InitialMagnification', 50);

%% キャリブレーションデータを用い、ステレオ平行化・表示
[J1, J2] = rectifyStereoImages(I1, I2, stereoParams);
% 表示
figure; imshow(stereoAnaglyph(J1, J2), 'InitialMagnification', 50);

%% 視差(カメラからの距離に半比例)の計算・視差マップの表示（近くが白）
%     disparityMapは、J1のPixel位置に対応。Singleタイプ配列。最小単位:1/16 Pixels
disparityMap = disparity(J1, J2);
figure; imshow(disparityMap, [0, 64], 'InitialMagnification', 50);

%% 画像の、3次元座標系への再構築・表示
%  視差マップ上の各点を3次元 world 座標系の点へマッピング
%  I1の光学中心がworld座標系の原点
pointCloud = reconstructScene(disparityMap, stereoParams);      %    % 799x1122x3 single: disparityMapの各ピクセルに対し、World座標系の[x,y.z]を計算し3次元部分に挿入
pointCloud = pointCloud / 1000;  %単位を mm から m へ変換

% カメラから0～4m離れた点のみプロット
z = pointCloud(:, :, 3);    % 距離のみ抽出
zdisp = z;
zdisp(z < 0 | z > 4) = NaN;   % 4mより近い・0mより離れている点を除去
pointCloud(:,:,3) = zdisp;
figure;showPointCloud(pointCloud, J1, 'VerticalAxis', 'Y',...
    'VerticalAxisDir', 'Down' );
xlabel('X');ylabel('Y');zlabel('Z');
xlim([-1 3]); ylim([-2 1]);
box on;

%% 別画像に対しての再構成例

%% 画像読み込み
I1 = imread('sceneReconstructionLeft.jpg');
I2 = imread('sceneReconstructionRight.jpg');
figure, imshowpair(I1,I2,'montage');

%% キャリブレーションデータを用い、ステレオ平行化・表示
load('webcamsSceneReconstruction.mat')    %保存してあるキャリブレーションデータ用いるとき
[J1, J2] = rectifyStereoImages(I1, I2, stereoParams);
% 表示
figure; imshow(stereoAnaglyph(J1, J2), 'InitialMagnification', 50);

%% 視差(カメラからの距離に半比例)の計算・視差マップの表示（近くが白）
%     disparityMapは、J1のPixel位置に対応。Singleタイプ配列。最小単位:1/16 Pixels
disparityMap = disparity(rgb2gray(J1), rgb2gray(J2));
figure; imshow(disparityMap, [0, 64], 'InitialMagnification', 50);



%% 画像の、3次元座標系への再構築・表示
%  視差マップ上の各点を3次元 world 座標系の点へマッピング
%  I1の光学中心がworld座標系の原点
pointCloud = reconstructScene(disparityMap, stereoParams);      %    % 799x1122x3 single: disparityMapの各ピクセルに対し、World座標系の[x,y.z]を計算し3次元部分に挿入
pointCloud = pointCloud / 1000;  %単位を mm から m へ変換

% カメラから3～7m離れた点のみプロット
z = pointCloud(:, :, 3);    % 距離のみ抽出
zdisp = z;
zdisp(z < 3 | z > 7) = NaN;   % 3mより近い・7mより離れている点を除去
pointCloud(:,:,3) = zdisp;
figure;showPointCloud(pointCloud, J1, 'VerticalAxis', 'Y',...
    'VerticalAxisDir', 'Down' );
xlabel('X');ylabel('Y');zlabel('Z');
xlim([-1 3]); ylim([-2 1]);
box on;
%%
% Copyright 2014 The MathWorks, Inc.
