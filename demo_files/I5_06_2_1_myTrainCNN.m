%% 畳込みニューラルネットワークのトレーニング *****************************************
% Computer Vision System Toolbox, Image Processing Toolbox
% Deep Learning Toolbox,Statistics and Machine Learning Toolbox,
% Parallel Computing Toolbox, CUDA-capable GPU card（ComputeCapability3.0以上）

%% 初期化
clear;close all;imtool close all;clc;rng('default')

%% 画像データの設定（数字をランダムなアフィン変換で変形したものを使用）
%     28x28ピクセルの8ビットグレースクール画像が10000枚
%     ディレクトリ名をラベルに (10000x1のカテゴリカル配列)
digitDatasetPath = fullfile(matlabroot,'toolbox','nnet','nndemos', ...
    'nndatasets','DigitDataset');
digitData = imageDatastore(digitDatasetPath,...
        'IncludeSubfolders',true, 'LabelSource','foldernames')

%% 画像の一部を表示（500枚）
figure; montage(digitData.Files(1:20:end)); truesize;

%% 各クラスの画像数の確認
digitData.countEachLabel

%% 学習用(75%)と検証用(25%)のデータセットに分割（各カテゴリ毎に半々）
[trainDigitData, testDigitData] = splitEachLabel(digitData, 0.75, 'randomize')
trainDigitData.countEachLabel

%% Layerクラス（CNN用のクラス）を使用し、CNNの構造を定義
%         DropOut層を用いる場合：例) dropoutLayer(0.4) % 学習データごとに、入力ノードの40%をランダムに0にして過学習を防止
layers = [imageInputLayer([28 28 1]);       % 入力画像サイズ：28x28x1、入力で明るさの正規化:0センター
          convolution2dLayer(5,20);         % 5x5x1のフィルタを20セット(マップ) (出力：24x24x20) 周囲のパディングなし
          reluLayer();                      % ReLU(Rectified Linear Unit)活性化関数層
          crossChannelNormalizationLayer(5, 'K',1);   % 5チャンネルの範囲で、チャネル間の正規化（パラメータは論文参照）
          maxPooling2dLayer(2,'Stride',2);  % max pooling層：2x2の領域内の最大値を出力  (出力：12x12x20) 領域内の平均移動への対応
            
          convolution2dLayer(5,16);         % 5x5x20のフィルタを16セット(マップ) (出力：8x8x16) 周囲のパディングなし
          reluLayer();                      % ReLU
          maxPooling2dLayer(2,'Stride',2);  % max pooling層：(出力：4x4x16 = 256次元)
               
          fullyConnectedLayer(10);          % 全結合層：入力256次元、出力10次元=カテゴリ数
          softmaxLayer();                   % 10個の入力に活性化関数として正規化指数関数を適応(全出力で正規化)し確立値へ変換
          classificationLayer()]            % 各カテゴリごとのスコアと、予測されたカテゴリを出力

%% Deep Network DesignerでCNNのレイヤーを定義可能
deepNetworkDesigner

%% 学習用オプションを、trainingOptions関数を用い設定
%     確率的勾配降下法（stochastic gradient descent with momentum）学習データの一部の値でパラメータを更新
%     必要であれば、GPUのメモリ量に応じてMiniBatchSizeを調整
opts = trainingOptions('sgdm', 'MaxEpochs',10, 'InitialLearnRate', 0.001,...
    'ValidationData',testDigitData,...
    'Plots','training-progress');     % 最大10世代まで学習、

%% [学習] ネットワークを教師付き学習（SeriesNetwork クラスのオブジェクトが学習後に生成される）
net = trainNetwork(trainDigitData, layers, opts);
%       load('I5_06_2_1_net.mat');           % あらかじめ学習した結果を用いる場合

%% [分類器の検証] 検証用画像2500枚の一部（250枚）を表示 ************************
figure; montage(testDigitData.Files(1:10:end)); truesize;

%% 検証用の画像を一枚読込み
I = imread(testDigitData.Files{521});
figure; imshow(I);

%% 学習したネットワークで分類
YPredClass = classify(net, I)

%% クラスへ分類(2500x1) と その際のスコア(2500x10) の計算
[YPredClass, YPredScore] = classify(net, testDigitData);             % predict関数はスコアのみ出力。必要であれば、GPUのメモリ量に応じてMiniBatchSizeを調整

%% 結果の表示：混合行列の計算 （1行目:0の文字を認識させた結果)
[confMat order] = confusionmat(testDigitData.Labels, YPredClass)

%% 全体の精度(平均)を計算
accuracy = sum(YPredClass == testDigitData.Labels)/numel(YPredClass)

%% 終了














%% 混合行列の単位をパーセントへ変換（要素単位演算）
confMat = bsxfun(@rdivide, confMat, sum(confMat,2))     % 1次元の方向を、一方のサイズに拡張して合わせる

%% 別のテスト画像を準備（Computer Vision Toolbox）**********************
%        imageDatasetへ、テスト画像（12枚x10文字種）への絶対パスを指定
pathData = [toolboxdir('vision'), '\visiondata\digits'];
testSet  = imageDatastore([pathData,'\handwritten'], 'LabelSource','foldernames', 'IncludeSubfolders',true)

%% 全テスト画像をモンタージュ表示 (12枚 x 10文字種)
figure; montage(testSet.Files, 'Size', [10,12]);

%% [識別] 作成した分類器で手書き数字(120枚)を識別
%        画像を読込む際に形式をそろえる：28x28pixel、白文字、グレースケール、double型
testSet.ReadFcn = @(filename) imresize(imcomplement(rgb2gray(imread(filename))), [28 28]);
YPredClass2 = classify(net, testSet);

%% [識別] 結果の表示
Ir = zeros([28,28,3,120], 'uint8');      % 結果を格納する配列
for k = 1:size(testSet.Labels,1)
  if YPredClass2(k) == testSet.Labels(k)    %正しい識別は青色、誤認識は赤色
    labelC = 'blue';
  else
    labelC = 'red';
  end
  Ir(:,:,:,k) = insertText(readimage(testSet,k),[6 4],char(YPredClass2(k)),'FontSize',16,'TextColor',labelC,'BoxOpacity',0.4); 
end
figure;montage(Ir, 'Size', [10,12]);

%% 終了




%% 第2層目（最初のフィルタ畳み込み層）の特性を可視化
%       （最初の層は基本的な画像の特徴:エッジや形状を抽出）
%        20セットのフィルタ係数（重み）を可視化
net.Layers(2) 
w1 = gather(net.Layers(2).Weights);      % 5x5x1 が 20セット(マップ)
w1g = mat2gray(w1);              % w1の要素の範囲を0~1へスケーリング
for k = 1:size(w1g, 4)
  w1a(:,:,k) = imadjust(imresize(w1g(:,:,:,k), 5, 'cubic'));   % 25x25ピクセルへ拡大、コントラスト調整
end
figure; montage(gather(reshape(w1a,[25 25 1 20])));    % 表示

%% 途中結果をmatファイルへ保存に使用した関数
%save('I5_06_2_1_net.mat', 'net');


%% Copyright 2016 The MathWorks, Inc.
