%% SSDによる物体検出器の学習
% このデモではSSDによる物体検出を行います。
% 実行には下記のToolboxが必要になります。
% Computer Vision Toolbox
% Deep Learning Toolbox
% Parallel Computing Toolbox(NVIDIA GPUでの学習・推論の高速化）
%
% Resnet50の読み込みには無償のアドオンをインストールが必要です。
% ※[ホーム]-[アドオン]からインストール


%% 初期化
clear; close all force; clc; rng('default');

%% 車両検出器用の学習データセットをロード
unzip vehicleDatasetImages.zip
data = load('vehicleDatasetGroundTruth.mat');
vehicleDataset = data.vehicleDataset;

%% 学習用データ(60%)とテスト用データ(40%)に分割
rng(0);
shuffledIndices = randperm(height(vehicleDataset));
idx = floor(0.6 * length(shuffledIndices) );
trainingData = vehicleDataset(shuffledIndices(1:idx),:);
testData = vehicleDataset(shuffledIndices(idx+1:end),:);

imdsTrain = imageDatastore(trainingData{:,'imageFilename'});
bldsTrain = boxLabelDatastore(trainingData(:,'vehicle'));

imdsTest = imageDatastore(testData{:,'imageFilename'});
bldsTest = boxLabelDatastore(testData(:,'vehicle'));

trainingData = combine(imdsTrain,bldsTrain);
testData = combine(imdsTest, bldsTest);


%% YOLO v2ネットワークを定義
% 入力画像サイズ
inputSize = [300 300 3];

% クラス数(今回は車両のみなので1個)
numClasses = width(vehicleDataset)-1;

% SSDネットワークの作成
lgraph = ssdLayers(inputSize, numClasses, 'resnet50');


%% データの水増しと前処理

% データの水増し(反転・移動)
augmentedTrainingData = transform(trainingData,@augmentData);
% 前処理（リサイズ）
preprocessedTrainingData = transform(augmentedTrainingData,@(data)preprocessData(data,inputSize));

%% 学習オプションを指定
options = trainingOptions('sgdm', ...
        'MiniBatchSize', 16, ....
        'InitialLearnRate',1e-1, ...
        'LearnRateSchedule', 'piecewise', ...
        'LearnRateDropPeriod', 30, ...
        'LearnRateDropFactor', 0.8, ...
        'MaxEpochs', 300, ...
        'VerboseFrequency', 50, ...        .
        'Shuffle','every-epoch');

%% カスタムのSSDネットワークの学習
[detector, info] = trainSSDObjectDetector(preprocessedTrainingData,lgraph,options);

% 学習済みモデルは以下でダウンロード可能
% disp('Downloading pretrained detector (44 MB)...');
% pretrainedURL = 'https://www.mathworks.com/supportfiles/vision/data/ssdResNet50VehicleExample_20a.mat';
% websave('ssdResNet50VehicleExample_20a.mat',pretrainedURL);
% pretrained = load('ssdResNet50VehicleExample_20a.mat');
% detector = pretrained.detector;

%% テスト画像の読み込みと検出
data = read(testData);
I = data{1,1};
I = imresize(I,inputSize(1:2));
[bboxes,scores] = detect(detector,I, 'Threshold', 0.4);

I = insertObjectAnnotation(I,'rectangle',bboxes,scores);
figure
imshow(I)


%% サポート関数

function B = augmentData(A)

B = cell(size(A));

I = A{1};
sz = size(I);

% ランダムに色味を変化
if numel(sz)==3 && sz(3) == 3
    I = jitterColorHSV(I,...
        'Contrast',0.2,...
        'Hue',0,...
        'Saturation',0.1,...
        'Brightness',0.2);
end

% ランダムに反転と拡大
tform = randomAffine2d('XReflection',true,'Scale',[1 1.1]);  
rout = affineOutputView(sz,tform,'BoundsStyle','CenterOutput');    
B{1} = imwarp(I,tform,'OutputView',rout);
[B{2},indices] = bboxwarp(A{2},tform,rout,'OverlapThreshold',0.25);    
B{3} = A{3}(indices);
    
% 境界ボックスが消えてしまう場合は元の画像を使用
if isempty(indices)
    B = A;
end
end

function data = preprocessData(data,targetSize)
% 画像と境界ボックスのリサイズ
scale = targetSize(1:2)./size(data{1},[1 2]);
data{1} = imresize(data{1},targetSize(1:2));
data{2} = bboxresize(data{2},scale);
end

%% _Copyright 2020 The MathWorks, Inc._
