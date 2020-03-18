%% HOG (Histogram of Oriented Gradient) 特徴量 と
%  SVM (Support Vector Machine) classifier を使った（2クラス分類）、手書き数字の識別
clear;clc;close all;imtool close all

%% トレーニング画像の準備
% トレーニング画像（101枚x10文字種）とテスト画像（12枚x10文字種）への絶対パスを設定
pathData = [toolboxdir('vision'), '\visiondata\digits']
trainSet = imageDatastore([pathData,'\synthetic'  ], 'LabelSource','foldernames', 'IncludeSubfolders',true)
testSet  = imageDatastore([pathData,'\handwritten'], 'LabelSource','foldernames', 'IncludeSubfolders',true);

%% トレーニング画像例の表示:一枚のみ（数字  2の学習用：4枚目）    readは1枚の画像のみ読込める
figure;imshow(readimage(trainSet, 206));

%% トレーニング用pos画像の表示
figure;montage(trainSet.Files(trainSet.Labels == '2'), 'Size', [ 6 17]);title('pos画像','FontSize',14); % pos画像
%% トレーニング用neg画像の表示
figure;montage(trainSet.Files(trainSet.Labels ~= '2'), 'Size', [23 40]);title('neg画像','FontSize',14); % neg画像
       
%% 全テスト画像をモンタージュ表示 (12枚 x 10文字種：各手書き数字から2を識別)
figure; montage(testSet.Files, 'Size', [10,12]);

%% 前処理結果の例 (数字2の例)：処理の実行・表示
%    前処理用（自動二値化）の関数：ノイズ除去し、特徴ベクトルの改善
exTrainImage  = readimage(trainSet, 206);     % 画像サイズ:16x16 pixels
img = imbinarize(rgb2gray(exTrainImage));

figure;
subplot(1,2,1); imshow(exTrainImage);
subplot(1,2,2); imshow(img);

%% HOG 特徴量パラメータ(CellSize)の最適化 (画像サイズ:16x16 pixels)

% HOG特徴量の抽出 (方向のBinは9つ)　(Blockサイズは2x2セル、Blockオーバーラップは1セル)
%    セル毎に、各Pixelのエッジ方向のヒストグラムを作成（9方向）
[hog_2x2, vis2x2] = extractHOGFeatures(img,'CellSize',[2 2]);  % セルサイズ:2x2pixel、セル数:8x8、block位置:7x7=49、特徴ベクトルの長さ:9方向x(2x2セル/ブロック)x49=1764次元
[hog_4x4, vis4x4] = extractHOGFeatures(img,'CellSize',[4 4]);  % セルサイズ:4x4pixel、セル数:4x4、block位置:3x3= 9、特徴ベクトルの長さ：9方向x(2x2セル/ブロック)x 9= 324次元
[hog_8x8, vis8x8] = extractHOGFeatures(img,'CellSize',[8 8]);  % セルサイズ:8x8pixel、セル数:2x2、block位置:1x1= 1、特徴ベクトルの長さ：9方向x(2x2セル/ブロック)   =  36次元

% 各セル毎に、抽出したヒストグラムの表示（ベクトルは、"輝度の勾配"の垂線）（セルが大きいと、模様の位置情報が減少）
figure; subplot(2,3,1:3); imshow(img);   % 元画像
subplot(2,3,4); plot(vis2x2); 
title({'CellSize = [2 2]'; ['Feature length = ' num2str(length(hog_2x2))]});
subplot(2,3,5); plot(vis4x4); 
title({'CellSize = [4 4]'; ['Feature length = ' num2str(length(hog_4x4))]});
subplot(2,3,6); plot(vis8x8); 
title({'CellSize = [8 8]'; ['Feature length = ' num2str(length(hog_8x8))]});

%% 4x4のセルサイズを使用 (324次元ベクトル)
cellSize = [4 4];
hogFeatureSize = length(hog_4x4);

%% [SVM分類器の学習] (数字の2)：fitcsvm() 関数を使用
% trainingFeatures を格納する配列をあらかじめ作成
trainingFeatures  = zeros(200,hogFeatureSize,'single');

% 全学習用画像(1010枚)からHOG特徴量を抽出 (PosとNeg共に)
for i = 1:size(trainSet.Labels,1)
  img = readimage(trainSet, i);  %トレーニング画像の読込み
  img = imbinarize(rgb2gray(img)); % 二値化
  trainingFeatures(i,:) = extractHOGFeatures(img,'CellSize',cellSize); %特徴量の抽出
end
trainingLabels = (trainSet.Labels == '2');   % ラベルの生成

% サポート ベクトル マシンの分類器の学習 
svmModel = fitcsvm(trainingFeatures, trainingLabels)

%svmModel = fitcsvm(trainingFeatures, trainingLabels, 'KernelFunction','polynomial', 'KernelOffset', 1, 'KernelScale','auto', 'Standardize','on')

%% [識別] 作成した分類器で手書き数字(120枚)から2を識別･表示：predict()
Ir = zeros([16,16,3,120], 'uint8');      % 結果を格納する配列
cntTrue = 0;
for i = 1:size(testSet.Labels,1)     % 各数字ごとに12枚の手書き文字
  img = readimage(testSet, i);
  BW  = imbinarize(img);     % 2値化

  testFeatures = extractHOGFeatures(BW,'CellSize',cellSize);
  predictedLabels = predict(svmModel, testFeatures);           % testFeature を配列にして、あとでまとめて判定も可
  % 2と認識したものに赤丸を挿入
  if predictedLabels
    img = insertShape(img,'Circle',[8,8,4],'Color','red');
    cntTrue = cntTrue+1;
  end
    Ir(:,:,:,i)=img;
end

% 結果の表示     数字'2'用の分類器で各手書き数字をテストした結果
figure;montage(Ir, 'Size', [10,12]);  title(['Correct Prediction: ' num2str(cntTrue)]);
%%












%% 分類学習器アプリケーションの使用
dataTable = table(trainingFeatures, trainingLabels, 'VariableNames',{'features', 'label'});     % 1x324 の特徴ベクトル + ラベル   が、200行
openvar('dataTable');
classificationLearner
  % 新規セッション => ワークスペースから
  % データのインポート：(デフォルトの、'列を変数として使用' を選択)
  % 一番下が、"応答"になっているのを確認
  %    予測子：学習用の特徴量（行:データ数 x 列:特徴量 の数値配列）
  %    応答 ： 教師データ（categorical array, cell array of strings, character array, logical, or numeric の列ベクトル）
  % 線形SVMを選択し -> 学習ボタン
  % Confusion Matrixの表示
  %   交差検定：N個のグループに分割し、#1を取り除き#2~#N-1のグループで学習し#1でテスト、次は#2を取り除き、、、、、を繰り返す
  %   ホールドアウト検定：一部のデータを、テスト用のデータとして取り除いたデータで学習：テスト用データに対し誤り率を評価
  %   検定なし          ：全ての学習データで学習：用いた全ての学習データで誤り率を計算
  % ROC (receiver operating characteristic curve) 曲線表示
  
  % モデルのエクスポート： trainedClassifier
  %      コンパクトモデル：学習データはエクスポートしない

  % SVM：データの標準化のデフォルトが、fitcsvmはfalse、分類学習器はtrue


%% [識別] アプリケーションで作成した分類器で手書き数字(120枚)から2を識別･表示：
Ir = zeros([16,16,3,120], 'uint8');      % 結果を格納する配列
for i = 1:size(testSet.Labels,1)     % 各数字ごとに12枚の手書き文字
  img = readimage(testSet, i);
  BW  = imbinarize(rgb2gray(img));     % 2値化

  features = extractHOGFeatures(BW,'CellSize',cellSize);
  predictedLabels = trainedClassifier.predictFcn(table(features));    % testFeature を配列にして、あとでまとめて判定も可
  % 2と認識したものに赤丸を挿入
  if predictedLabels
    img = insertShape(img,'Circle',[8,8,4],'Color','red');
  end
    Ir(:,:,:,i)=img;
end
% 結果の表示     数字'2'用の分類器で各手書き数字をテストした結果
figure;montage(Ir, 'Size', [10,12]);
  

% ClassificationPartitionedModel 交差検定分類器の生成
CVSVMModel = crossval(svmModel);
classLoss = kfoldLoss(CVSVMModel)    % 標本外誤判別率を推定します。
  
% Copyright 2013-2014 The MathWorks, Inc.
% 画像データセット
% トレーニング画像：insertText関数で自動作成 (周囲に別の数字有り)
% テスト画像：手書きの画像を使用
