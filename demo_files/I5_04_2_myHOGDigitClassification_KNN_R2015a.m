%% HOG (Histogram of Oriented Gradient) 特徴量 と
%  k最近傍分類器：KNN (k-nearest neighbor) classifier を使った、手書き数字の識別
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

%% [KNN分類器の構築]：fitcknnを使用
% 10文字分のtrainingFeatures を格納する配列をあらかじめ作製
trainingFeatures  = zeros(10*101,hogFeatureSize, 'single');
trainingLabels    = zeros(10*101,1);

% HOG特徴量を抽出
for digit = 0:9   % 文字'0'～'9'
  for i = 1:101         % 各数字ごとに101枚のトレーニング用画像
    img = read(trainSet(digit+1), i);  %トレーニング画像の読込み       trainSet()は、1から始まるので、+1
    img = im2bw(img,graythresh(img));   % 二値化
             
    trainingFeatures((digit)*101+i,:) = extractHOGFeatures(img,'CellSize',cellSize);
    trainingLabels((digit)*101+i)     = digit;
  end
end
% KNN分類器の学習 (k=5)
knnModel5 = fitcknn(trainingFeatures, trainingLabels, 'NumNeighbors', 5)    %近いもの5つを取り多数決

%% [識別] 作成した分類器で手書き数字(120枚)を識別･表示：predict()
Ir = zeros([16,16,3,120], 'uint8');      % 結果を格納する配列
cntTrue = 0;
for digit = 0:9   % 
  for i = 1:12         % 各数字ごとに12枚の手書き文字
    img = read(testSet(digit+1), i);    % testSet()は、1から始まるので、+1
    BW = im2bw(img,graythresh(img));    % 2値化

    testFeatures = extractHOGFeatures(BW,'CellSize',cellSize);
    predictedNum = predict(knnModel5, testFeatures);           % testFeature を配列にして、あとでまとめて判定も可
    
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

%%








%% Copyright 2013-2014 The MathWorks, Inc.
% 画像データセット
% トレーニング画像：insertText関数で自動作成 (周囲に別の数字有り)
% テスト画像：手書きの画像を使用
