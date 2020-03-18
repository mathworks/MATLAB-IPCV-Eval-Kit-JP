%% ディープラーニング転移学習(SVM)による画像分類
% 学習済みCNNとSVMを使った転移学習

%% 初期化
clear; close all; imtool close all; clc;rng('default')

%% 学習させたい画像セットの準備（ここでは６つのカテゴリの画像を使用）%%%%%%%%%%%%%%%%%%%%%%
%  http://www.vision.caltech.edu/Image_Datasets/Caltech101 Caltech 101
if ~exist('101_ObjectCategories','dir')
    websave('101_ObjectCategories.tar.gz','http://www.vision.caltech.edu/Image_Datasets/Caltech101/101_ObjectCategories.tar.gz');
    gunzip('101_ObjectCategories.tar.gz');
    untar('101_ObjectCategories.tar','101_ObjectCategories');
end
rootFolder = fullfile('101_ObjectCategories','101_ObjectCategories');          % 画像セットへのパス
categ = {'cup', 'pizza', 'watch', 'laptop'};

%% カップ
winopen(fullfile(rootFolder,categ{1}));

%% ピザ
winopen(fullfile(rootFolder,categ{2}));

%% 腕時計
winopen(fullfile(rootFolder,categ{3}));

%% ラップトップPC
winopen(fullfile(rootFolder,categ{4}));

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

%% Pre-trained Convolutional Neural Network (CNN) の読込み %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
convnet = alexnet   % SeriesNetworkクラス：25層

%% 構成されている層の表示（畳み込み層:5層、全結合層:3層）
convnet.Layers

%% 第一層目（入力層）の詳細表示
convnet.Layers(1)      % 入力画像サイズは、227x227x3で固定、正規化有り

%% ネットワークに画像を入力するための前処理関数
% convnetへの入力画像サイズ：227x227ピクセルのRGB画像へ揃える為。予測の際もこのサイズへ変換される
% ImageDatastore の ReadFcn 関数を設定
imds.ReadFcn = @(filename) I5_06_2_2_readAndPreproc(filename);

%% CNN内部の処理例：第2層目（最初のフィルタ畳み込み層）の特性を可視化
%       （最初の層は基本的な画像の特徴:エッジや形状を抽出）
% 96セットのフィルタ係数（重み）を可視化
convnet.Layers(2)                  % 第2層目の詳細
w1 = convnet.Layers(2).Weights;    % 11x11x3 Singleが 96セット(マップ)
w1s = mat2gray(w1);                 % w1の要素の範囲を0~1へスケーリング
for k = 1:size(convnet.Layers(2).Weights, 4)
  I = imresize(w1s(:,:,:,k), 5, 'nearest');     % 33x33ピクセルへ拡大、コントラスト調整
  w1a(:,:,:,k) = imadjust(I, stretchlim(I));
end
figure; montage(w1a);               % 表示

%% 例）63番目のフィルタで畳込み処理・表示
figure; imshow(w1a(:,:,:,63),[]); truesize; shg;  % フィルタ係数を可視化
%% 画像例を読込み･表示
Is = readimage(imds, 1);
figure;subplot(1,2,1); imshow(Is); shg;
%% フィルタ処理･表示
F = w1(:,:,:,63);                     % フィルタ係数指定
Isf = convn(Is, F, 'valid');          % 畳み込み計算
subplot(1,2,2); imshow(Isf, []); shg; % 表示

%% 最終層の確認
convnet.Layers(end)     % ImageNetデータセットの1000クラスを分類するように学習済み

%% 各カテゴリの画像を、学習データ(90%)とテストデータ(10%)に分ける
[trainingSet, testSet] = splitEachLabel(imds, 0.9);    % randomize オプションも有

%% [学習ステップ#1] 後方のレイヤーfc7(23層中の19番目)の出力を
%                     特徴量として引き出す（4096次元）
% GPUのメモリに応じて、MiniBatchSizeを調整
% 特徴量を縦(第１次元方向)にし、fitcecocのトレーニングを高速化（fitcecocで、ObservationsInを設定）
fLayer = 'fc7';
trainingFeatures = activations(convnet, trainingSet, fLayer, ...   % CPUでは実行時間必要
                   'MiniBatchSize', 32, 'OutputAs', 'columns');    % 4096x126 各列が各画像に対応

%% [学習ステップ#2] 多クラス分類器を学習（ECOC誤り訂正出力符号 多クラスモデル、線形分類器）
% 多次元特徴量の学習に適した、solver（fast Stochastic Gradient Descent）を使用
classifier = fitcecoc(trainingFeatures,trainingSet.Labels , ...
        'Learners', 'Linear', 'Coding', 'onevsall', 'ObservationsIn', 'columns');

      
%% 例）取り分けておいた、テスト画像の10枚目を分類 **********************************
I1 = imread(testSet.Files{10});      % 画像を一枚読込み（例：10枚目）
figure; imshow(I1);                  % 画像の表示

%% [分類ステップ#1]
imageFeatures = activations(convnet, readimage(testSet, 10),...
    fLayer,'OutputAs','rows');   % 特徴量を計算

%% [分類ステップ#2]･表示
label = predict(classifier, imageFeatures)      % 学習した分類器により分類
% 結果の表示
imshow(insertText(I1, [10 70], char(label), 'FontSize',20)); shg;       % 認識結果を挿入･表示

%% 同様にすべてのテスト画像を用い、分類器の性能評価
% すべてのテスト用画像から特徴量を計算
testFeatures = activations(convnet, testSet, fLayer, 'MiniBatchSize',32,...
    'OutputAs','rows');   % 特徴量を計算
% 今回学習した多クラス分類器による分類
predictedLabels = predict(classifier, testFeatures);
% 混合行列の計算 （1行目:飛行機の画像を認識させた結果)
[confMat order] = confusionmat(testSet.Labels, predictedLabels)

%% 性能評価
% 混合行列の単位をパーセントへ変換（要素単位演算）
confMat = bsxfun(@rdivide,confMat,sum(confMat,2))  % 1次元の方向を、一方のサイズに拡張して合わせる
% 全体の精度(平均)を計算
mean(diag(confMat))

%% 生成した分類器(SVM)を保存
save('I5_06_2_2_myCNNTransferLearning_SVM.mat', 'classifier');

%% Copyright 2018 The MathWorks, Inc
% Copyright 2018 The MathWorks, Inc.