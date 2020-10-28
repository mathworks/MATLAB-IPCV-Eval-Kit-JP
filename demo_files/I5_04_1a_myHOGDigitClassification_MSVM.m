%% HOG (Histogram of Oriented Gradient) 特徴量 と
%  マルチクラス SVM を使った、手書き数字の識別
clear;clc;close all;imtool close all

% トレーニング画像（101枚x10文字種）とテスト画像（12枚x10文字種）への絶対パスを設定
pathData = [toolboxdir('vision'), '\visiondata\digits']
trainSet = imageSet([pathData,'\synthetic'  ], 'recursive');
testSet  = imageSet([pathData,'\handwritten'], 'recursive');

%% 全トレーニング用画像例の表示
figure;montage([trainSet.ImageLocation], 'Size', [26 40]);

%% 全テスト画像をモンタージュ表示 (12枚 x 10文字種：各手書き数字を認識)
figure;montage([testSet(:).ImageLocation], 'Size', [10,12]);

%% 4x4のセルサイズを使用 (324次元ベクトル)
cellSize = [4 4];
hogFeatureSize = 324;                   % length(hog_4x4)

%% [分類器の構築]：fitcecocを使用
% 10文字分のtrainingFeatures を格納する配列をあらかじめ作製
trainingFeatures  = zeros(10*101,hogFeatureSize, 'single');
trainingLabels    = zeros(10*101,1);

% HOG特徴量を抽出
for digit = 0:9   % 文字'0'～'9'
  for i = 1:101         % 各数字ごとに101枚のトレーニング用画像
    img = read(trainSet(digit+1), i);  %トレーニング画像の読込み       trainSet()は、1から始まるので、+1
    img = imbinarize(img,graythresh(img));   % 二値化
             
    trainingFeatures((digit)*101+i,:) = extractHOGFeatures(img,'CellSize',cellSize);
    trainingLabels((digit)*101+i)     = digit;
  end
end
% 多クラス分類器の学習（ECOC誤り訂正符号 多クラスモデル）
svmModel = fitcecoc(trainingFeatures, trainingLabels)

%% [識別] 作成した分類器で手書き数字(120枚)を識別･表示：predict()
Ir = zeros([16,16,3,120], 'uint8');      % 結果を格納する配列
cntTrue = 0;
for digit = 0:9   % 
  for i = 1:12         % 各数字ごとに12枚の手書き文字
    img = read(testSet(digit+1), i);    % testSet()は、1から始まるので、+1
    BW = imbinarize(img,graythresh(img));    % 2値化

    testFeatures = extractHOGFeatures(BW,'CellSize',cellSize);
    predictedNum = predict(svmModel, testFeatures);           % testFeature を配列にして、あとでまとめて判定も可
    
    if predictedNum == digit    %正しい識別は青色、誤認識は赤色
      Ir(:,:,:,digit*12+i) = insertText(img,[6 4],num2str(predictedNum),'FontSize',9,'TextColor','blue','BoxOpacity',0.4);
      cntTrue = cntTrue+1;
    else
      Ir(:,:,:,digit*12+i) = insertText(img,[6 4],num2str(predictedNum),'FontSize',9,'TextColor','red','BoxOpacity',0.4); 
    end 

  end
end
% 結果の表示
figure;montage(Ir, 'Size', [10,12]); title(['Correct Prediction: ' num2str(cntTrue)]);

%% 終了






%% APPを使った分類器の生成
dataTable = table(trainingFeatures, trainingLabels, 'VariableNames',{'features', 'label'});     % 1x324 の特徴ベクトル + ラベル   が、200行
openvar('dataTable');
classificationLearner
  % 新規セッション => ワークスペースから
  % データのインポート：(デフォルトの、'列を変数として使用' を選択)
  % 一番下を、"予測子"から"応答"へ変更
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
%%
Ir = zeros([16,16,3,120], 'uint8');      % 結果を格納する配列
cntTrue = 0;
for digit = 0:9   % 
  for i = 1:12         % 各数字ごとに12枚の手書き文字
    img = read(testSet(digit+1), i);    % testSet()は、1から始まるので、+1
    BW = imbinarize(img,graythresh(img));    % 2値化

    features = extractHOGFeatures(BW,'CellSize',cellSize);
    predictedNum = trainedClassifier.predictFcn(table(features));           % testFeature を配列にして、あとでまとめて判定も可
    
    if predictedNum == digit    %正しい識別は青色、誤認識は赤色
      Ir(:,:,:,digit*12+i) = insertText(img,[6 4],num2str(predictedNum),'FontSize',9,'TextColor','blue','BoxOpacity',0.4);
      cntTrue = cntTrue+1;
    else
      Ir(:,:,:,digit*12+i) = insertText(img,[6 4],num2str(predictedNum),'FontSize',9,'TextColor','red','BoxOpacity',0.4); 
    end 

  end
end
% 結果の表示
figure;montage(Ir, 'Size', [10,12]); title(['Correct Prediction: ' num2str(cntTrue)]);

%% 終了








%% 符号化設計行列を表示 :1対1 符号化設計（学習器数：K(K-1)/2 ）
CodingMat = svmModel.CodingMatrix
%% 別の符号化設計： 1対他 符号化設計（学習器数：K ）
svmModel = fitcecoc(trainingFeatures, trainingLabels, 'Coding','onevsall')
CodingMat = svmModel.CodingMatrix

%% 別の符号化設計：完全2項 符号化設計 (常に全てのクラスを使用、学習器数：2^(K-1) -1)
svmModel = fitcecoc(trainingFeatures, trainingLabels, 'Coding','binarycomplete')
CodingMat = svmModel.CodingMatrix


%% Copyright 2013-2014 The MathWorks, Inc.
% 画像データセット
% トレーニング画像：insertText関数で自動作成 (周囲に別の数字有り)
% テスト画像：手書きの画像を使用

% 符号化設計行列を表示 :1対1 符号化設計（学習器数：K(K-1)/2 ）
CodingMat = svmModel.CodingMatrix
