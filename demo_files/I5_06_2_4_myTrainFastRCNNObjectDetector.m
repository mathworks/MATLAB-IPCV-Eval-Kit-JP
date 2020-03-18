%% Fast R-CNNによる物体検出器の学習

%% 初期化
clear; close all force; clc; rng('default');

%% 学習データの読み込み
data = load('rcnnStopSigns.mat', 'stopSigns', 'fastRCNNLayers');
stopSigns = data.stopSigns;
fastRCNNLayers = data.fastRCNNLayers;

%% 画像ファイルのフルパス指定
stopSigns.imageFilename = fullfile(toolboxdir('vision'),'visiondata', ...
    stopSigns.imageFilename);

%% 学習オプションの指定
options = trainingOptions('sgdm', ...
    'MiniBatchSize', 1, ...
    'InitialLearnRate', 1e-3, ...
    'MaxEpochs', 10);

%% Fast R-CNN物体検出器を学習
% GPUの使用推奨
frcnn = trainFastRCNNObjectDetector(stopSigns, fastRCNNLayers , options, ...
    'NegativeOverlapRange', [0 0.1], ...
    'PositiveOverlapRange', [0.7 1], ...
    'SmallestImageDimension', 600);

%% 学習したFast R-CNN物体検出器をテスト
img = imread('stopSignTest.jpg');
[bbox, score, label] = detect(frcnn, img);

%% 結果を表示
detectedImg = insertShape(img, 'Rectangle', bbox);
figure
imshow(detectedImg)

%%
% Copyright 2018 The MathWorks, Inc.