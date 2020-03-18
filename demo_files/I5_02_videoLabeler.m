%% Video Labelerによるラベリングと検出器学習

%% 初期化
clc;clear;close all;imtool close all; rng('default');

%% 予めラベリングしたgroundTruthオブジェクトのパスを修正
d = load('I5_02_videoLabeler_GroundTruth.mat');
gTruth = d.gTruth;
oldPathDataSource = "C:\Program Files\MATLAB\R2018b\toolbox\vision\visiondata";
newPathDataSource= fullfile(toolboxdir('vision'),"visiondata");
alterPaths = [oldPathDataSource newPathDataSource];
unresolvedPaths = changeFilePaths(gTruth,alterPaths);

%% Video Labeler を起動：下記コマンドもしくはアプリタブから
videoLabeler('visiontraffic.avi')

% ROIラベルの定義」セクションの「新しいROIラベルの定義」で「car」をRectangleとして作る
% 各画像で車両をドラッグで囲む
% ラベリング済みデータを取り込む場合は「ラベルをインポート」→「ワークスペースから」で
%　gTruthを選択

b%% groundTruthオブジェクトから学習データ生成
imDir = 'I5_02_trainingImages';
[~,~,~] = mkdir(imDir);
trainingData  = objectDetectorTrainingData(d.gTruth,'WriteLocation',imDir);

%% テスト画像1枚と残りの学習画像に分ける
testData = trainingData(15,:);
trainingData(15,:) = [];

%% 学習オプションの指定
options = trainingOptions('sgdm', ...
    'MiniBatchSize', 1, ...
    'InitialLearnRate', 1e-3, ...
    'MaxEpochs', 3, ...
    'VerboseFrequency', 200);

%% Faster R-CNN物体検出器を学習
% GPUの使用推奨
detector = trainFasterRCNNObjectDetector(trainingData, 'alexnet', options)

%% 学習したFaster R-CNN物体検出器をテスト
% テスト画像読み込み
img = imread(testData.imageFilename{1});
% 物体検出
[bboxes, scores, labels] = detect(detector, img);
% 結果を表示
detectedImg = insertObjectAnnotation(img, 'Rectangle', bboxes, cellstr(labels));
figure, imshow(detectedImg)

%%
% Copyright 2018 The MathWorks, Inc.