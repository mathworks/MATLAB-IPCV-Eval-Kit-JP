%% レンズ歪の補正
clear;clc;close all;close all force

%% カメラキャリブレーション用の画像の確認
imageFolder = fullfile(toolboxdir('vision'), 'visiondata', ...
    'calibration', 'mono');
winopen(imageFolder);

%% アプリケーションの起動
squareSize = 29;  % 升目一つのサイズ（単位：mm）
cameraCalibrator(imageFolder,squareSize);

%% 推定したカメラパラメータの読込
%   (もしくは アプリケーションのキャリブレーション結果を使用)
load('I2_02_calibration_cameraParams');

%% 任意の対象画像の読込
imds = imageDatastore(imageFolder);
origI = imds.readimage(1);
figure;imshow(origI)

%% 画像の歪補正･表示 :デフォルトでは、"入出力画像は同サイズ,原点Originは不変, i.e., newOrigin=(0,0)"
[undistI, ~] = undistortImage(origI, cameraParams);
figure;imshowpair(origI,undistI);truesize;

%% 終了















%% カメラの外部パラメータの可視化（カメラを固定）
figure; showExtrinsics(cameraParams, 'CameraCentric');

%% 画像上の点座標に対してレンズ歪補正
points = detectCheckerboardPoints(origI)
figure; imshow(origI);
hold on;
plot(points(:, 1), points(:, 2), 'g*');
hold off;

% 画像に対して、レンズ歪除去
[undistI, newOrigin] = undistortImage(origI, cameraParams, 'OutputView','full');
% 点座標に対して、レンズ歪除去
undistPoints = undistortPoints(points, cameraParams);
% 点座標のアライメント
undistPoints = [undistPoints(:,1) - newOrigin(1), undistPoints(:,2) - newOrigin(2)];

% 結果の表示
figure; imshow(undistI);
hold on;
plot(undistPoints(:, 1), undistPoints(:, 2), 'r*');
hold off;

%% 画像の歪補正(全体を残す)･表示
[undistI, newOrigin] = undistortImage(origI, cameraParams, 'OutputView', 'full');
figure;imshowpair(origI, undistI, 'montage');

%% 画像上の点座標が与えられたときの歪補正・表示
[points, boardSize] = detectCheckerboardPoints(origI)   % pointsに入っている点座標をこのあとに歪補正
undistPoints = undistortPoints(points, cameraParams);   % 歪補正
figure;imshow(origI);hold on;
plot(undistPoints(:,1), undistPoints(:,2), 'g*');hold off;
%% (歪補正した画像に重ね合わせ)
undistPoints = [undistPoints(:,1) - newOrigin(1), undistPoints(:,2) - newOrigin(2)];   % undistortImageで、画像全体が入るように画像サイズが変わる設定にしたため、重ねるには点の座標の移動が必要
figure;imshow(undistI);hold on;
plot(undistPoints(:,1), undistPoints(:,2), 'g*');hold off;

%% チェッカーボードを固定して外部パラメータの表示 %%%%%%%%%%%%%%%%%%
figure; showExtrinsics(cameraParams, 'PatternCentric');

%% 画像がチェッカーパターンを含むときは以下が可能
%    レンズ歪補正後、そのチェッカーパターンをWorld座標系の原点にして、
%    それに対するカメラの位置（外部パラメータ）推定
squareSize = 150;   % 単位：mm
worldPoints = generateCheckerboardPoints(boardSize, squareSize);  %World座標系での理想コーナー点座標を計算。左上のコーナー点が(0,0)
% 歪補正した画像からの交点座標・World座標系での交点座標と、cameraParams内のintrinsicsから、
%    回転(R)と並進(T)の行列を計算（カメラの位置：外部パラメータを推定）
%    worldPointがX,Yのみの場合は、Z=0を使用
%       [x y z] = [X Y Z]R + T         % [x y z]:カメラ座標、[X Y Z]:World座標
[rotationMatrix, translationVector] = extrinsics(flipud(undistPoints), worldPoints, cameraParams)

%% レンズ歪補正後の画像上の左上チェッカーコーナー点を、World座標系のXYへ変換 (World座標系で交点はz=0)
%     cameraParams.WorldUnits：mm
worldPoint1 = pointsToWorld(cameraParams, rotationMatrix, translationVector, undistPoints(1,:))

%% レンズ歪補正画像上の(2,2)チェッカーコーナー点を、World座標系のXYへ変換
worldPoint2 = pointsToWorld(cameraParams, rotationMatrix, translationVector, undistPoints(8,:))

%% World座標（上記 worldPoint2、z=0)を、逆に画像上の座標へ変換
%     w [x y 1] = [X Y Z 1] * [R;t] * K        : wは任意の係数、[X Y Z]はWorld座標系、Kはカメラ内部パラメータ
%    camMatrix = [rotationMatrix; translationVector] × K
camMatrix = cameraMatrix(cameraParams, rotationMatrix, translationVector)   % Projection Matrix (4x3)
imagePointsP = [worldPoint2, 0, 1] * camMatrix
imagePoints = imagePointsP / imagePointsP(3)

%% チェッカーボードの原点に対する（World座標系での）、カメラの位置
%    カメラ座標の原点に対応する、World座標
orientation = rotationMatrix'
location = -translationVector * orientation

%% キャリブレーションに用いた4番目の、チェッカーボードの原点に対するカメラの位置
rotationMatrix = cameraParams.RotationMatrices(:,:,6)
translationVector = cameraParams.TranslationVectors(6,:)
orientation = rotationMatrix'
location = -translationVector * orientation



%% [pointsToWorld関数を使わない場合：R2014a以前] World座標系から画像座標系への変換行列を計算
R = rotationMatrix;
t = translationVector;
T = [R(1, :); R(2, :); t] * cameraParams.IntrinsicMatrix
tform2 = projective2d(T)      % 求めた変換行列から、2次元射影幾何学変換用のオブジェクトを作成

%% 画像上の"点" undistPoints1を、World座標系へ変換する場合には、作成したtformの逆変換を適用
% 画像上の点 undistPointsを、world coordinate座標（実位置）へ変換するときは次行
worldPoints1a = transformPointsInverse(tform2, undistPoints(8,:))

%% 2次元データ(画像)をWorld座標系(カメラに向き合う姿勢、カメラの中心が原点)へ変換（1pixel = 1mm）
birdsEyeView1 = imwarp(undistI, invert(tform2));   %Create the Bird's-Eye View
imtool(birdsEyeView1);
%% World座標系の原点を、画像の左上隅にして再表示（1pixel = 1mm）
birdsEyeView2 = imwarp(undistI, invert(tform2), 'OutputView', imref2d([750 900]));   %Create the Bird's-Eye View
imtool(birdsEyeView2);

% Copyright 2014 The MathWorks, Inc.
