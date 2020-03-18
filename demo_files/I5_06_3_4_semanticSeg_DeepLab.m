%% DeepLab v3+によるセマンティックセグメンテーション

%% 初期化
clear; close all ;clc; rng('default');

%% 学習データの準備
dataSetDir = fullfile(toolboxdir('vision'),'visiondata','triangleImages');
imageDir = fullfile(dataSetDir,'trainingImages');
imds = imageDatastore(imageDir);

%% ラベルデータの準備
labelDir = fullfile(dataSetDir, 'trainingLabels');
classNames = ["triangle","background"];
labelIDs   = [255 0];
pxds = pixelLabelDatastore(labelDir,classNames,labelIDs);

%% DeepLab v3+ネットワークの準備
imageSize = [256 256];
numClasses = numel(classNames);
lgraph = deeplabv3plusLayers(imageSize,numClasses,'resnet18');

%% 学習データの準備
pximds = pixelLabelImageDatastore(imds,pxds,'OutputSize',imageSize,...
    'ColorPreprocessing','gray2rgb');

%% 学習オプション
opts = trainingOptions('sgdm',...
    'MiniBatchSize',8,...
    'MaxEpochs',3,...
    'Plots','training-progress');

%% 学習
net = trainNetwork(pximds,lgraph,opts);

%% テスト画像で評価
I = imread('triangleTest.jpg');
I = imresize(I,'Scale',imageSize./32);
C = semanticseg(I,net);
B = labeloverlay(I,C);
figure
imshow(B)

%%
% Copyright 2019 The MathWorks, Inc.