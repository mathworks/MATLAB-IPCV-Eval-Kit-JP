clc;close all;imtool close all;clear;

%% 左右の動画像を読込むオブジェクトの作成
readerLeft = vision.VideoFileReader('handshake_left.avi', ...
    'VideoOutputDataType','uint8', 'ImageColorSpace','Intensity', 'PlayCount',inf);
readerRight = vision.VideoFileReader('handshake_right.avi', ...
     'VideoOutputDataType', 'uint8', 'ImageColorSpace','Intensity', 'PlayCount',inf);
%% 動画を表示するためのオブジェクトを作成
playerDisparity = vision.DeployableVideoPlayer();
playerRGB = vision.DeployableVideoPlayer();
%% 人物検出のオブジェクトを作成
detector = vision.PeopleDetector('MinSize',[160 80], 'MaxSize',[400 200], 'UseROI',true);  % 人物検出

%% ステレオキャリブレーション結果の読込み
load('handshakeStereoParams.mat');

%% Stop ボタン表示
a=true;
sz = get(0,'ScreenSize');
figure('MenuBar','none','Toolbar','none','Position',[20 sz(4)-100 100 70])
uicontrol('Style', 'pushbutton', 'String', 'Stop',...
        'Position', [20 20 80 40],...
        'Callback', 'a=false;');

%% メインループ
badDisparity = -realmax('single');
previousDisparityMap = [];
while (a)
%for i=1:30
    % 左右のフレームの読込み
    frameLeft = step(readerLeft);
    frameRight = step(readerRight);
    
    % ステレオ平行化
    [frameLeftRect, frameRightRect] = rectifyStereoImages(frameLeft,...
        frameRight, stereoParams, 'OutputView', 'valid');
    
    % 視差(左右の画像の差：近いと大きい)計算
    disparityMap = disparity(frameLeftRect, frameRightRect, 'DisparityRange',[0 32]);
    
    % 視差が測定できていない部分は、前フレーム値を代入
    badIdx = (disparityMap == badDisparity);
    if ~isempty(previousDisparityMap)         %1stフレームでは行わない
      disparityMap(badIdx) = previousDisparityMap(badIdx);
    end
    step(playerDisparity, disparityMap / 64);  %視差画像の表示 (最大Disparity値は64)
    previousDisparityMap = disparityMap;      %次フレーム用に現在の視差画像を保存
    
    % 3D再構築：world(実)座標系へ変換（frameLeftの光学中心が座標の中心）
    pointCloud = reconstructScene(disparityMap, stereoParams);
    
    % 人物検出・中心座標・中心線形インデックスの計算
    bboxes = step(detector, frameRightRect, [100,100,460,410]);
    centroids = round(bboxes(:, 1:2) + bboxes(:, 3:4) / 2);
    centroidsIdx = sub2ind(size(disparityMap), centroids(:, 2), centroids(:, 1));
    
    % 人物の中心座標の距離を求める
    Z = pointCloud(:, :, 3);       %距離の2次元行列を生成
    zs = Z(centroidsIdx) / 1000;   %単位をmmからmへ変換
    
    colors = zeros(size(bboxes, 1), 3);
    tooClose = 3;
    colors(zs > tooClose, 2) = 255;  % 3m以遠であれば緑色枠
    colors(zs <= tooClose, 1) = 255; % 3m以内であれば赤色枠
    
    % 人物の周りに色付き境界ボックス・人物までの距離を表示
    dispFrame = insertObjectAnnotation(frameRightRect, 'rectangle', bboxes,...
        cellstr([num2str(zs) repmat('m',size(zs))]), 'Color', colors, 'FontSize',22);

    % RGBフレームの表示
   step(playerRGB, dispFrame);
    
    % フレームのスキップ
    frameLeft = step(readerLeft);frameRight = step(readerRight);
    frameLeft = step(readerLeft);frameRight = step(readerRight);
    
   drawnow limitrate;             % プッシュボタンのイベントの確認
end

release(readerLeft);
release(readerRight);
release(playerDisparity);
release(playerRGB);
release(detector);


%% Copyright 2014 The MathWorks, Inc.




