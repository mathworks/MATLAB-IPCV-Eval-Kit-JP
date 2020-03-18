%% Train R-CNN (regions with convolutional neural networks) Stop Sign Detector
% 転移学習を使用
% Image Processing Toolbox, Computer Vision System Toolbox
% Neural Network Toolbox, Statistics and Machine Learning Toolbox, Parallel Computing Toolboxのライセンスが必要。（分類の実行のみでも同様）
clc;clear;close all;imtool close all;

%% データの読込み
% 'stopSigns'：画像ファイル名とROI、'layers'：学習済み Network Layers.
load('rcnnStopSigns.mat', 'stopSigns', 'layers')
layers         % 15層：学習済み Network Layersの確認
% 画像へのパスを設定
imDir = [matlabroot, '\toolbox\vision\visiondata\stopSignImages'];
addpath(imDir);

%% 読込んだROIの確認
imageLabeler     % stopSignsをワークスペースから読込み

%% トレーニングオプションの設定
options = trainingOptions('sgdm', ...
  'MiniBatchSize', 32, ...            % デフォルトの128から下げる（GPUメモリ使用量低減）
  'InitialLearnRate', 1e-6, ...       % デフォルト：0.01からさげる（PreTrainingモデルからFineTuningするため）
  'MaxEpochs', 10);

%% R-CNNのトレーニングの実行（ラベリング済み画像データと、学習済みネットワークを入力）
%rcnn = trainRCNNObjectDetector(stopSigns, layers, options, 'NegativeOverlapRange', [0 0.3]);
load('I5_06_2_3_myRcnn.mat');      % あらかじめ学習したネットワークを読込み


%% テスト用画像の読込み・表示
I = imread('stopSignTest.jpg');
figure; imshow(I)

%% 検出し結果を画像上に表示（CPUでは実行時間必要）
[bbox, score, label] = detect(rcnn, I, 'MiniBatchSize', 32);    % RCNNで検出

I1 = insertObjectAnnotation(I, 'rectangle', bbox, char(label), 'FontSize',18);
figure; imshow(I1)        % 表示

%% 画像へのパスを消去
rmpath(imDir); 

%%










%% R-CNNのトレーニングの実行（ラベリング済み画像データと、学習済みネットワークを入力）
% When the network is a SeriesNetwork, the network layers are automatically adjusted to support
% the number of object classes defined within the groundTruth training data.
% The background is added as an additional class.

% When the network is an array of Layer objects, the network must have a classification layer
% that supports the number of object classes, plus a background class. Use this input type to
% customize the learning rates of each layer. You can also use this input type to resume training
% from a previous session. Resuming the training is useful when the network requires additional
% rounds of fine-tuning, and when you want to train with additional training data.

% 実行した際のメッセージ
% *******************************************************************
% Training an R-CNN Object Detector for the following object classes:
% 
% * stopSign
% 
% Step 1 of 3: Extracting region proposals from 27 training images...done.
% 
% Step 2 of 3: Training a neural network to classify objects in training data...
% 
% |=========================================================================================|
% |     Epoch    |   Iteration  | Time Elapsed |  Mini-batch  |  Mini-batch  | Base Learning|
% |              |              |  (seconds)   |     Loss     |   Accuracy   |     Rate     |
% |=========================================================================================|
% |            3 |           50 |         6.13 |       0.2895 |       96.88% |     0.000001 |
% |            5 |          100 |        10.23 |       0.2443 |       93.75% |     0.000001 |
% |            8 |          150 |        14.50 |       0.0013 |      100.00% |     0.000001 |
% |           10 |          200 |        18.64 |       0.1524 |       96.88% |     0.000001 |
% |=========================================================================================|
% 
% Network training complete.
% 
% Step 3 of 3: Training bounding box regression models for each object class...100.00%...done.
% 
% R-CNN training complete.
% *******************************************************************
% Copyright 2018 The MathWorks, Inc.