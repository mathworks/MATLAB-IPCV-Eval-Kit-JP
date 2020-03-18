%% HOG (Histogram of Oriented Gradient) 特徴量 と
%  決定木（2分木） を使った、手書き数字の識別
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

%% [分類木の構築]：fitctreeを使用
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
% 分類木の学習
treeModel = fitctree(trainingFeatures, trainingLabels, 'MaxNumSplits',4)

%% 分類ツリービューアーで、生成したツリーを表示
%    x番号は、特徴量の番号
view(treeModel, 'mode','graph');

%% [識別] 作成した分類器で手書き数字(120枚)を識別･表示：predict()
Ir = zeros([16,16,3,120], 'uint8');      % 結果を格納する配列
cntTrue = 0;
for digit = 0:9   % 
  for i = 1:12         % 各数字ごとに12枚の手書き文字
    img = read(testSet(digit+1), i);    % testSet()は、1から始まるので、+1
    BW = im2bw(img,graythresh(img));    % 2値化

    testFeatures = extractHOGFeatures(BW,'CellSize',cellSize);
    predictedNum = predict(treeModel, testFeatures);           % testFeature を配列にして、あとでまとめて判定も可
    
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


%% アンサンブル学習 (ClassificationBaggedEnsemble クラスが返る)
%   バギング決定木 => ランダムフォレスト アルゴリズムを使用
template = templateTree('MaxNumSplits', 20);
bagModel = fitcensemble(...
	trainingFeatures, trainingLabels, ...
	'Method', 'Bag', ...
	'NumLearningCycles', 30, 'Learners', template);

%% bagModel.Trainedは、 CompactClassificationTreeクラスのセル配列
%       Children : ノード番号順に、そのノードがつながっている2つのノード番号。終端ノードに関しては0 0 が入る
%       CutPredictor : 各ノードでの分岐に用いる特徴量番号
%       CutPoint : 分岐の閾値 (終端ノードに関しては、NaNが入る)
%       NodeClass : 各ノードでの分類されたクラス
view(bagModel.Trained{3})
view(bagModel.Trained{3}, 'mode','graph')




%% 分類学習器アプリケーションの使用
%   バギング決定木は、ランダムフォレスト
%   構造体のメンバーとして、ClassificationEnsemble (CompactClassificationEnsembleクラス)  が返る
%   各ClassificationEnsemble.Trained{k}が、CompactClassificationTreeクラスのオブジェクト
dataTable = table(trainingFeatures, trainingLabels, 'VariableNames',{'features', 'label'});     % 1x324 の特徴ベクトル + ラベル   が、200行
openvar('dataTable');
classificationLearner

% コンパクトモデルのエクスポート：trainedClassifier
view(trainedClassifier.ClassificationEnsemble.Trained{1}, 'mode','graph')

%% [識別] 作成した分類器で手書き数字(120枚)を識別･表示：trainedClassifier.predictFcn()
Ir = zeros([16,16,3,120], 'uint8');      % 結果を格納する配列
cntTrue = 0;
for digit = 0:9   % 
  for i = 1:12         % 各数字ごとに12枚の手書き文字
    img = read(testSet(digit+1), i);    % testSet()は、1から始まるので、+1
    BW = im2bw(img,graythresh(img));    % 2値化

    features = extractHOGFeatures(BW,'CellSize',cellSize);
		predictedNum = trainedClassifier.predictFcn(table(features));    % testFeature を配列にして、あとでまとめて判定も可
 
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




%% Copyright 2013-2014 The MathWorks, Inc.
% 画像データセット
% トレーニング画像：insertText関数で自動作成 (周囲に別の数字有り)
% テスト画像：手書きの画像を使用
