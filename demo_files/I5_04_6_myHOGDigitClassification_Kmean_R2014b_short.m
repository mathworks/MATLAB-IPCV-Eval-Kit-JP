%% HOG (Histogram of Oriented Gradient) 特徴量 と
%  k平均：k-Means Clustering を使った、手書き数字の分類
clear;clc;close all;imtool close all

% 手書き数字画像（12枚x10文字種）への絶対パスを設定
pathData = [toolboxdir('vision'), '\visiondata\digits\handwritten']
trainSet  = imageSet(pathData, 'recursive');

%% 手書き数字画像をモンタージュ表示 (12枚 x 10文字種)
figure;montage([trainSet.ImageLocation], 'Size', [10,12]);

%% 4x4のセルサイズを使用 (324次元ベクトル)
cellSize = [4 4];
hogFeatureSize = 324;                   % length(hog_4x4)

%% k平均クラスタリング
% 10文字分のtrainingFeatures を格納する配列をあらかじめ作製
trainingFeatures  = zeros(10*12,hogFeatureSize, 'single');

% HOG特徴量を抽出
for digit = 1:10   % 1=>文字'0'
  for i = 1:12         % 各手書き数字ごとに12枚のトレーニング用画像
    img = read(trainSet(digit), i);  %トレーニング画像の読込み
    img = imbinarize(img,graythresh(img));   % 二値化
             
    trainingFeatures((digit-1)*12+i,:) = extractHOGFeatures(img,'CellSize',cellSize);
  end
end
% K平均クラスタリングの実行
result = kmeans(trainingFeatures, 10)    %10個のグループに分類

%% 10個のクラスタ毎に、結果の表示
figure; Ir = [];
for k = 1:10
  for digit = 0:9
    for i = 1:12         % 各数字ごとに12枚の手書き文字
      if result((digit)*12+i) == k
        img = read(trainSet(digit+1), i);                     
        Ir = [Ir img];
      end
    end
  end
  subplot(10,1,k); imshow(Ir); Ir = [];
end
%% 終了













%% 別形式の結果表示
Ir = zeros([16,16,3,120], 'uint8');      % 結果を格納する配列
for digit = 0:9
  for i = 1:12         % 各数字ごとに12枚の手書き文字
    img = read(trainSet(digit+1), i);                     
    Ir(:,:,:,(digit)*12+i) = insertText(img,[6 4],char(64+result((digit)*12+i)),'FontSize',10,'TextColor','blue','BoxOpacity',0.4);
  end
end
% 表示
figure;montage(Ir, 'Size', [10,12]);

%% Copyright 2013-2014 The MathWorks, Inc.
% 画像データセット
% トレーニング画像：insertText関数で自動作成 (周囲に別の数字有り)
% テスト画像：手書きの画像を使用
