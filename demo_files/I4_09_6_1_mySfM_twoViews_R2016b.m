%% 2つの画像からの、Structure From Motion
%     キャリブレーション済みのカメラで撮影した2枚の2次元画像から、
%     3D構造構築と、それぞれの画像に対応するカメラ位置･姿勢推定
% [フロー]
%  [それぞれの画像に対する、カメラ自己位置･姿勢推定]
%   1: 2つの画像で疎な対応点を探索
%      （画像1から特徴点検出し、画像2へポイントトラック）
%      （特徴点検出と特徴量マッチィングの方法もあり）
%   2: 基本行列の推定（2つの画像の対応関係）と、誤対応点の除去
%   3: 基本行列と対応点座標を用い、カメラ1に対する、カメラ2の位置･姿勢を推定
%  [3次元再構築]
%   4: カメラ1･2の位置･姿勢関係から、それぞれのカメラ行列(World座標と画像の座標の関係)を計算
%   5: 2つの画像で密な対応点を再探索
%   6: それぞれのカメラ行列を用い、対応点の3次元位置を計算
%  [実スケールへ補正]
%   7: 大きさが既知の物体を点群にフィティングし、点群のスケールを計算
%   8: 求めたスケールを用いて、絶対スケールの3次元点群へ変換

clc;clear;close all;imtool close all; rng('default');

%% 2枚の画像の読込み・表示
imgDir = [matlabroot '\toolbox\vision\visiondata\upToScaleReconstructionImages\'];
I1 = imread([imgDir 'globe1.jpg']);
I2 = imread([imgDir 'globe2.jpg']);
figure; imshowpair(I1, I2, 'montage'); title('Original Images');truesize;

%% それぞれの画像からレンズ歪の除去
load upToScaleReconstructionCameraParameters.mat  % カメラパラメータの読込み（内部パラメータ・歪係数）
I1u = undistortImage(I1, cameraParams);
I2u = undistortImage(I2, cameraParams);
imshowpair(I1u, I2u, 'montage'); title('Undistorted Images');truesize;shg;

%% [それぞれの画像に対する、カメラ自己位置･姿勢推定] %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2つの画像間で対応する点を見つける
% 画像1内の疎なコーナー点を検出・表示 (約400点)
%      画面全体に満遍なく検出するため、MinQuality設定で、検出されるコーナー点数を低減
imagePoints1 = detectMinEigenFeatures(rgb2gray(I1u), 'MinQuality', 0.1);
figure; imshow(I1u); truesize;
hold on; plot(imagePoints1);

%%
% 移動が小さいので、ポイントトラッカーを用い画像間の対応点を探索
% 先ずポイントトラッカーのオブジェクトを生成
tracker = vision.PointTracker('MaxBidirectionalError', 1, 'NumPyramidLevels', 5);
% 画像1上のコーナー点の座標でポイントトラッカーを初期化
initialize(tracker, imagePoints1.Location, I1u);
% ポイントトラッカーで、画像2上の対応点を検索
[imagePointsLoc2, validIdx] = step(tracker, I2u);
% 結果の表示
matchedPoints1 = imagePoints1.Location(validIdx, :);
matchedPoints2 = imagePointsLoc2(validIdx, :);
figure; showMatchedFeatures(I1u, I2u, matchedPoints1, matchedPoints2);  % Figure内で拡大して確認

%% 基本行列の推定・誤対応点(outlier)の除去･結果の表示
%  （2つの画像上の点の対応関係を求め、エピポーラ拘束を満たさない点を除去）
[E, epipolarInliers] = estimateEssentialMatrix(...
      matchedPoints1, matchedPoints2, cameraParams, 'Confidence', 99.99);

inlierPoints1 = matchedPoints1(epipolarInliers, :);
inlierPoints2 = matchedPoints2(epipolarInliers, :);
figure;
showMatchedFeatures(I1u, I2u, inlierPoints1, inlierPoints2); title('Epipolar Inliers');

%% 画像1に対する、画像2のカメラ位置･姿勢(Orientation)を計算
%    スケール不定のため、L(位置)は単位ベクトルと仮定
%    O : Orientation、L：Location
[O, L] = relativeCameraPose(E, cameraParams, inlierPoints1, inlierPoints2)

%% 2台のカメラ位置関係を可視化
figure; grid on; hold on
plotCamera('Size',0.1,'Color','b','Label','start');  % 1番目のカメラを原点に描画
plotCamera('Location',L, 'Orientation',O, 'Size',0.1, ...
                      'Color','r','Label','finish');
xlabel('X'); ylabel('Y'); zlabel('Z'); view(3);
xlim([-0.4 1.4]);ylim([-0.3 0.3]);zlim([-0.2 1.6]);box on;
axis equal

%% [3次元再構築] %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% カメラ1･2の位置･姿勢の関係から、それぞれのカメラ行列(World座標と画像の座標の関係)を計算
%      World座標の原点を画像1のカメラ位置、カメラの方向をZ軸の正にする
t1 = [0 0 0];      % カメラ1はWorld座標原点と設定（並進移動なし）
R1 = eye(3);       % カメラ1はWorld座標Z軸の正方向と設定（回転なし）
%t2 = -L*O';       % カメラ2への並進ベクトル（外部パラメータ）
%R2 = O';          % カメラ2への回転行列（外部パラメータ）
[R2, t2] = cameraPoseToExtrinsics(O, L);     % R2016b
camMatrix1 = cameraMatrix(cameraParams, R1, t1);
camMatrix2 = cameraMatrix(cameraParams, R2, t2);

%% 2つの画像で、密な対応点を再検索
% MinQualityを下げて、多くの(密な)特徴点を最検出
roi = [30, 30, size(I1u, 2) - 30, size(I1u, 1) - 30];   % 画像端を除去
imagePoints1 = detectMinEigenFeatures(rgb2gray(I1u), 'ROI',roi, 'MinQuality', 0.001);

% ポイントトラッカーのオブジェクトを再度生成
tracker = vision.PointTracker('MaxBidirectionalError', 1, 'NumPyramidLevels', 5);
% ポイントトラッカーを、画像1上の密な特徴点座標で初期化
initialize(tracker, imagePoints1.Location, I1u);

% ポイントトラッカーで、画像2上の対応点を検索
[imagePointsLoc2, validIdx] = step(tracker, I2u);
matchedPoints1 = imagePoints1.Location(validIdx, :);
matchedPoints2 = imagePointsLoc2(validIdx, :);

%% 対応点それぞれの、3次元位置を計算
points3D = triangulate(matchedPoints1, matchedPoints2, camMatrix1, camMatrix2);         % Direct Linear Transformation (DLT) algorithm

% 画像1からそれぞれの点の色情報を抽出
numPixels = size(I1u, 1) * size(I1u, 2);
allColors = reshape(I1u, [numPixels, 3]);
colorIdx = sub2ind([size(I1u, 1), size(I1u, 2)], round(matchedPoints1(:,2)), ...
    round(matchedPoints1(:, 1)));
color = allColors(colorIdx, :);

% 3次元点群の生成 (pointCloudクラス)
ptCloud = pointCloud(points3D, 'Color', color)

%% 再構築された3次元点群の表示
figure; grid on; hold on
plotCamera('Size', 0.3, 'Color', 'r', 'Label', '1', 'Opacity', 0);
plotCamera('Location', L, 'Orientation', O, 'Size', 0.3, ...
                  'Color', 'b', 'Label', '2', 'Opacity', 0);
pcshow(ptCloud, 'VerticalAxis', 'y', 'VerticalAxisDir', 'down', ...
              'MarkerSize', 45);
camorbit(0, -30);     % 見る角度を回転
xlabel('X'); ylabel('Y'); zlabel('Z');
xlim([-6 6]);ylim([-5 5]);zlim([-1 15]);box on;title('任意スケール')

%% [実スケールへ補正] %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 点群に、球をフィッティングして地球儀の位置を検出･表示
globe = pcfitsphere(ptCloud, 0.1)    % 球のフィッティング（最大距離誤差0.1）
plot(globe);      % 球を重ね書き
hold off; shg;

%% 地球儀の既知の大きさを用い、絶対距離の点群に変換
scaleFactor = 10 / globe.Radius;    % 地球儀の半径:10cm
ptCloud = pointCloud(points3D * scaleFactor, 'Color', color);
Ls = L * scaleFactor;        % カメラ位置2の座標も絶対距離へ変換

% 絶対距離で、再可視化
figure; grid on; hold on;
plotCamera('Size', 2, 'Color', 'r', 'Label', '1', 'Opacity', 0);
plotCamera('Location', Ls, 'Orientation', O, 'Size', 2, ...
                'Color', 'b', 'Label', '2', 'Opacity', 0);
pcshow(ptCloud, 'VerticalAxis', 'y', 'VerticalAxisDir', 'down', ...
                'MarkerSize', 45);
camorbit(0, -30);
xlabel('X (cm)'); ylabel('Y (cm)'); zlabel('Z (cm)');
xlim([-40 40]);ylim([-30 30]);zlim([-5 85]);box on;

%% Copyright 2016 The MathWorks, Inc.
