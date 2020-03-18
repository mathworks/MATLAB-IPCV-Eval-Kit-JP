%% ディープラーニング転移学習による画像分類

%% 初期化
clear; close all; imtool close all; clc;rng('default');

%% 学習させたい画像セットの準備（ここでは６つのカテゴリの画像を使用）
%  http://www.vision.caltech.edu/Image_Datasets/Caltech101 Caltech 101
if ~exist('101_ObjectCategories','dir')
    websave('101_ObjectCategories.tar.gz','http://www.vision.caltech.edu/Image_Datasets/Caltech101/101_ObjectCategories.tar.gz');
    gunzip('101_ObjectCategories.tar.gz');
    untar('101_ObjectCategories.tar','101_ObjectCategories');
end
rootFolder = fullfile('101_ObjectCategories','101_ObjectCategories');          % 画像セットへのパス
categ = {'cup', 'pizza', 'watch', 'laptop'};

%% ImageDatastore クラスへ学習画像の情報を登録
% ３つのカテゴリの画像のファイ名を取り込む（フォルダの名前を、ラベル名にする）：画像そのものはまだ読込まない
%       Files： ファイル名：セル配列
%       Labels：ラベル    ：カテゴリカル配列
imds = imageDatastore(fullfile(rootFolder, categ), 'LabelSource', 'foldernames')
% 各カテゴリの画像の枚数の確認
tbl = countEachLabel(imds)
% 各カテゴリのデータ数を、最小のものにそろえる
imds = splitEachLabel(imds, min(tbl{:,2}));  % randomizeオプションも有
countEachLabel(imds)                         % 各カテゴリの画像の枚数の確認

%% 学習データとテストデータに分ける
[imdsTrain,imdsValidation] = splitEachLabel(imds,0.9);

%% 学習画像の可視化
numTrainImages = numel(imdsTrain.Labels);
idx = randperm(numTrainImages,16);
figure
for i = 1:16
    subplot(4,4,i)
    I = readimage(imdsTrain,idx(i));
    imshow(I)
end

%% 学習済みモデルをロード
net = alexnet;
analyzeNetwork(net) % 可視化
inputSize = net.Layers(1).InputSize

%% 転移学習用に後段を変更
layersTransfer = net.Layers(1:end-3); % 後段の層を除去
numClasses = numel(categories(imdsTrain.Labels)) % クラス数取得
layers = [
    layersTransfer
    fullyConnectedLayer(numClasses,'WeightLearnRateFactor',20,'BiasLearnRateFactor',20)
    softmaxLayer
    classificationLayer];

%% 学習データの水増し
pixelRange = [-30 30]; % -30画素から30画素でランダムに上下に動かす
imageAugmenter = imageDataAugmenter( ...
    'RandXReflection',true, ...
    'RandXTranslation',pixelRange, ...
    'RandYTranslation',pixelRange);
augimdsTrain = augmentedImageDatastore(inputSize(1:2),imdsTrain, ...
    'DataAugmentation',imageAugmenter,...
    'ColorPreprocessing','gray2rgb'); % 入力画像サイズ変更
augimdsValidation = augmentedImageDatastore(inputSize(1:2),imdsValidation,...
    'ColorPreprocessing','gray2rgb');

%% 学習オプションの指定
options = trainingOptions('sgdm', ...
    'MiniBatchSize',16, ...
    'MaxEpochs',3, ...
    'InitialLearnRate',1e-4, ...
    'ValidationData',augimdsValidation, ...
    'ValidationFrequency',10, ...
    'ValidationPatience',Inf, ...
    'Verbose',false, ...
    'Plots','training-progress');

%% 学習を実行
netTransfer = trainNetwork(augimdsTrain,layers,options);

%% 学習したモデルを使ってテスト
[YPred,scores] = classify(netTransfer,augimdsValidation);
accuracy = mean(YPred == imdsValidation.Labels)

%% 可視化
idx = randperm(numel(imdsValidation.Files),4);
figure
for i = 1:4
    subplot(4,1,i)
    I = readimage(imdsValidation,idx(i));
    imshow(I)
    label = YPred(idx(i));
    title(string(label));
end

%% 生成した分類器を保存
save('I5_06_2_2_myCNNTransferLearning.mat', 'netTransfer');

%% 
% Copyright 2018 The MathWorks, Inc.
