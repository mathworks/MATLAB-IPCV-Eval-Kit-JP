%% Faster R-CNNによる物体検出器の学習

%% 初期化
clear; close all force; clc; rng('default');

%% 学習データの読み込み
data = load('fasterRCNNVehicleTrainingData.mat');
trainingData = data.vehicleTrainingData;
trainingData.imageFilename = fullfile(toolboxdir('vision'),'visiondata', ...
    trainingData.imageFilename);
layers = data.layers
analyzeNetwork(layers);

%% 学習オプションの指定
options = trainingOptions('sgdm', ...
    'MiniBatchSize', 1, ...
    'InitialLearnRate', 1e-3, ...
    'MaxEpochs', 5, ...
    'VerboseFrequency', 200);

%% Faster R-CNN物体検出器を学習
% GPUの使用推奨
detector = trainFasterRCNNObjectDetector(trainingData, layers, options)

%% 学習したFaster R-CNN物体検出器をテスト
img = imread('highway.png');
[bbox, score, label] = detect(detector, img);

%% 結果を表示
detectedImg = insertShape(img, 'Rectangle', bbox);
figure
imshow(detectedImg)

%%
% Copyright 2018 The MathWorks, Inc.