%% FCN(Fully Convolutional Network)によるセマンティックセグメンテーション

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

%% FCNの準備
numFilters = 64;
filterSize = 3;
numClasses = 2;
layers = [
    imageInputLayer([32 32 1])
    convolution2dLayer(filterSize,numFilters,'Padding',1)
    reluLayer()
    maxPooling2dLayer(2,'Stride',2)
    convolution2dLayer(filterSize,numFilters,'Padding',1)
    reluLayer()
    transposedConv2dLayer(4,numFilters,'Stride',2,'Cropping',1);
    convolution2dLayer(1,numClasses);
    softmaxLayer()
    pixelClassificationLayer()
    ]

% VGG16ベースのFCNを構築するfcnLayersも使用可能
% (ただし、画像が224x224以上必要)
% layers = fcnLayers([224 224],numClasses);

%% 学習オプション
opts = trainingOptions('sgdm', ...
    'InitialLearnRate',1e-3, ...
    'MaxEpochs',100, ...
    'MiniBatchSize',64,...
    'Plots','training-progress');

%% ラベルの頻度から重み計算
tbl = countEachLabel(trainingData)
totalNumberOfPixels = sum(tbl.PixelCount);
frequency = tbl.PixelCount / totalNumberOfPixels;
classWeights = 1./frequency
layers(end) = pixelClassificationLayer('Classes',tbl.Name,'ClassWeights',classWeights);

%% 学習
net = trainNetwork(trainingData,layers,opts);

%% テスト画像で評価
testImage = imread('triangleTest.jpg');
imshow(testImage)
C = semanticseg(testImage,net);
B = labeloverlay(testImage,C);
imshow(B)

%%
% Copyright 2018 The MathWorks, Inc.