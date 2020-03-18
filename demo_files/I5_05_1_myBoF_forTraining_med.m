%% Bag of Visual Words ･ Bag of Features による画像のガテゴリ分類
% 赤血球に寄生した病原虫の分類
% バベシア症 / マラリア原虫 / トリパノソーマ症
clc;close all;imtool close all;clear; rng('default');

%% 画像データの準備
%  カテゴリ毎に画像ファイル名を、Image Set クラスへ格納・画像例表示
%              画像のソース： http://www.cdc.gov/dpdx/index.html    (Centers for Disease Control and Prevention)
if ~exist('classifyBloodSmearImages','dir')
    websave('classifyBloodSmearImages.zip','https://jp.mathworks.com/matlabcentral/mlc-downloads/downloads/submissions/66881/versions/3/download/zip')
    unzip('classifyBloodSmearImages.zip');
end
rootFolder = 'classifyBloodSmearImages\BloodSmearImages';              % 画像へのパスの指定

%% 画像データの読み込み
imgSets = imageSet(rootFolder, 'recursive')
% 各カテゴリの最初の画像を表示
figure; subplot(1,3,1);imshow(read(imgSets(1),1));title(imgSets(1).Description, 'FontSize',16);
        subplot(1,3,2);imshow(read(imgSets(2),1));title(imgSets(2).Description, 'FontSize',16);
        subplot(1,3,3);imshow(read(imgSets(3),1));title(imgSets(3).Description, 'FontSize',16); truesize;

%% 全画像の表示 (それぞれ16枚ずつ)
figure;subplot(1,3,1);montage([imgSets(1).ImageLocation]);title(imgSets(1).Description, 'FontSize',16);
       subplot(1,3,2);montage([imgSets(2).ImageLocation]);title(imgSets(2).Description, 'FontSize',16);
       subplot(1,3,3);montage([imgSets(3).ImageLocation]);title(imgSets(3).Description, 'FontSize',16); truesize;

%% 各カテゴリの画像を、学習用画像(15枚)と検証用画像(1枚)に分ける：partition メソッド
[trainingSets, validationSets] = partition(imgSets, 15);                 % randomized オプションもあり

%% Visual Words (局所的な模様)の集合を、生成（デフォルト設定：500個）
%   全カテゴリーに対し、縦横それぞれ8ピクセル間隔のグリッド上の点で、各[32 64 96 128]の4つの領域サイズで特徴量を抽出
%   ワード数 500個に、K-meansでグループ化
% Parallel Computing Toolbox オプションあれば、並列計算も可能  (設定メニュー内のComputer Vision System Toolbox設定内で設定)
% カスタムの特徴量抽出関数の指定も可能
%   あらかじめ生成し保存してある場合にはそれを読込み：
%   load('I5_05_Parasitology_img\I5_05_1_bag_med.mat')
bag = bagOfFeatures(trainingSets);

%% 例）一番目のトレーニング画像の featureVector (Visual Wordsのヒストグラム) を表示
img1 = read(trainingSets(1), 1);       % 画像の読込み
img2 = read(trainingSets(2), 1);
img3 = read(trainingSets(3), 1);
figure;subplot(2,3,1);imshow(img1);title(trainingSets(1).Description, 'FontSize',14); % 画像の表示
       subplot(2,3,2);imshow(img2);title(trainingSets(2).Description, 'FontSize',14);
       subplot(2,3,3);imshow(img3);title(trainingSets(3).Description, 'FontSize',14);

% Visual Wordsヒストグラムを生成 (1x500 single)･表示
featureVector1 = encode(bag, img1);
featureVector2 = encode(bag, img2);
featureVector3 = encode(bag, img3);
subplot(2,3,4); bar(featureVector1);xlabel('Visual word index');ylabel('Frequency of occurrence');xlim([1 500]);
subplot(2,3,5); bar(featureVector2);xlabel('Visual word index');ylabel('Frequency of occurrence');xlim([1 500]);
subplot(2,3,6); bar(featureVector3);xlabel('Visual word index');ylabel('Frequency of occurrence');xlim([1 500]);shg;

%% 各学習用画像を Visual Wordsのヒストグラムで表し、機械学習（multiclass linear SVM classifier）
categoryClassifier = trainImageCategoryClassifier(trainingSets, bag);

%% 取り分けておいた、テスト画像を用いて検証 %%%%%%%%%
%  encodeで、各画像に対するヒストグラムを表示
img1 = read(validationSets(1), 1);    % 画像の読込み
img2 = read(validationSets(2), 1);
img3 = read(validationSets(3), 1);
figure;subplot(2,3,1);imshow(img1);title(['(' validationSets(1).Description ')'], 'FontSize',14); % 画像の表示
       subplot(2,3,2);imshow(img2);title(['(' validationSets(2).Description ')'], 'FontSize',14);
       subplot(2,3,3);imshow(img3);title(['(' validationSets(3).Description ')'], 'FontSize',14);

featureVector1 = encode(bag, img1,  'Normalization', 'none');     % Visual Wordsヒストグラムを生成 (1x500 single)
featureVector2 = encode(bag, img2,  'Normalization', 'none');     % Visual Wordsヒストグラムを生成 (1x500 single)
featureVector3 = encode(bag, img3,  'Normalization', 'none');     % Visual Wordsヒストグラムを生成 (1x500 single)
subplot(2,3,4);bar(featureVector1); xlabel('Visual word index'); ylabel('Frequency of occurrence'); xlim([1, 500]);
subplot(2,3,5);bar(featureVector2); xlabel('Visual word index'); ylabel('Frequency of occurrence'); xlim([1, 500]);
subplot(2,3,6);bar(featureVector3); xlabel('Visual word index'); ylabel('Frequency of occurrence'); xlim([1, 500]);

%% predictで分類・結果を画像に挿入
[labelIdx1, scores] = predict(categoryClassifier, img1);
[labelIdx2, scores] = predict(categoryClassifier, img2);
[labelIdx3, scores] = predict(categoryClassifier, img3);
img1 = insertText(img1, [1 1], categoryClassifier.Labels(labelIdx1), 'FontSize', 30, 'BoxOpacity',1, 'Font','Meiryo');
img2 = insertText(img2, [1 1], categoryClassifier.Labels(labelIdx2), 'FontSize', 30, 'BoxOpacity',1, 'Font','Meiryo');
img3 = insertText(img3, [1 1], categoryClassifier.Labels(labelIdx3), 'FontSize', 30, 'BoxOpacity',1, 'Font','Meiryo');
subplot(2,3,1);imshow(img1);title(['(' validationSets(1).Description ')'], 'FontSize',14);
subplot(2,3,2);imshow(img2);title(['(' validationSets(2).Description ')'], 'FontSize',14);
subplot(2,3,3);imshow(img3);title(['(' validationSets(3).Description ')'], 'FontSize',14);shg;

%% 学習データを用い、再代入誤り率の計算
confMatrix = evaluate(categoryClassifier, trainingSets);         % （1に近い数値が右下がり対角線に並ぶ）

%% 終了















%% データベースを保存
% save('I5_05_1b_bag_med.mat', 'bag');

%% 取り分けておいた、テスト画像に対して、分類器の性能を評価
confMatrix = evaluate(categoryClassifier, validationSets);

%% Copyright 2016 The MathWorks, Inc. 

