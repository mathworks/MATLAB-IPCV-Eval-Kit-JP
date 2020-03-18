%% SegNetによるセマンティックセグメンテーション

%% 初期化
clear; close all ;clc; rng('default');

%% 学習データの準備
dataSetDir = fullfile(toolboxdir('vision'),'visiondata','triangleImages');
imageDir = fullfile(dataSetDir,'trainingImages');
imds = imageDatastore(imageDir);

%% ラベルデータの準備
classNames = ["triangle","background"];
labelIDs   = [255 0];
labelDir = fullfile(dataSetDir,'trainingLabels');
pxds = pixelLabelDatastore(labelDir,classNames,labelIDs);

%% 学習データとラベルデータの可視化
I = read(imds);
C = read(pxds);

I = imresize(I,5);
L = imresize(uint8(C),5);
figure, imshowpair(I,L,'montage')

%% 学習データの準備
augmenter = imageDataAugmenter('RandRotation',[-10 10],'RandXReflection',true)
trainingData = pixelLabelImageDatastore(imds,pxds,'DataAugmentation',augmenter)

%% SegNetの準備
imageSize = [32 32];
numClasses = 2;
lgraph = segnetLayers(imageSize,numClasses,2)

%% 学習オプション
opts = trainingOptions('sgdm', ...
    'InitialLearnRate',1e-3, ...
    'MaxEpochs',20, ...
    'MiniBatchSize',64,...
    'Plots','training-progress');

%% ラベルの頻度から重み計算
tbl = countEachLabel(trainingData)
totalNumberOfPixels = sum(tbl.PixelCount);
frequency = tbl.PixelCount / totalNumberOfPixels;
classWeights = 1./frequency
pxLayer = pixelClassificationLayer('Name','labels','ClassNames',tbl.Name,'ClassWeights',classWeights)
lgraph = removeLayers(lgraph,'pixelLabels');
lgraph = addLayers(lgraph, pxLayer);
lgraph = connectLayers(lgraph,'softmax','labels');
analyzeNetwork(lgraph);

%% 学習
net = trainNetwork(trainingData,lgraph,opts);

%% テスト画像で評価
testImage = imread('triangleTest.jpg');
imshow(testImage)
C = semanticseg(testImage,net);
B = labeloverlay(testImage,C);
imshow(B)

%%
% Copyright 2018 The MathWorks, Inc.