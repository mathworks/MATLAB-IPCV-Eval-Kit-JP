%% YOLO v2による物体検出器の学習

%% 初期化
clear; close all force; clc; rng('default');

%% 車両検出器用の学習データセットをロード
data = load('vehicleTrainingData.mat');
trainingData = data.vehicleTrainingData;
dataDir = fullfile(toolboxdir('vision'),'visiondata');
trainingData.imageFilename = fullfile(dataDir,trainingData.imageFilename);

%% YOLO v2ネットワークを定義
% 入力画像サイズ
imageSize = [128 128 3];

% クラス数(今回は車両のみなので1個)
numClasses = width(trainingData)-1;

% アンカーボックス
anchorBoxes = [
    43 59
    18 22
    23 29
    84 109
];

% 学習済みモデル
baseNetwork = resnet50;

% 特徴抽出の層を指定
featureLayer = 'activation_40_relu';

% YOLO v2検出ネットワークの作成
lgraph = yolov2Layers(imageSize,numClasses,anchorBoxes,baseNetwork,featureLayer);

%% 深層学習ネットワークアナライザーで整合確認
analyzeNetwork(lgraph)

%% YOLO v2の学習オプションを指定
options = trainingOptions('sgdm',...
          'InitialLearnRate',0.001,...
          'Verbose',true,...
          'MiniBatchSize',16,...
          'MaxEpochs',30,...
          'Shuffle','every-epoch',...
          'VerboseFrequency',30,...
          'CheckpointPath',tempdir);

%% YOLO v2物体検出器を学習
[detector,info] = trainYOLOv2ObjectDetector(trainingData,lgraph,options);

%% 損失関数の推移を確認
figure
plot(info.TrainingLoss)
grid on
xlabel('繰り返し回数')
ylabel('損失関数')

%% テスト画像の読み込みと検出
img = imread('detectcars.png');
[bboxes,scores] = detect(detector,img);
if(~isempty(bboxes))
    img = insertObjectAnnotation(img,'rectangle',bboxes,scores);
end
figure
imshow(img)

%%
% _Copyright 2019 The MathWorks, Inc._
