%% 機械学習デモ：前方車両の検出
clc;clear;close all;imtool close all;

%% Image Labeler を起動：下記コマンドもしくはアプリタブから
imageLabeler

% 「読み込み」→「フォルダーからイメージを追加」 
% I5_02_cars 内の画像を追加（実際は数百枚以上の画像を使用）
% もしくは下記のコマンドで起動
% imageLabeler('I5_02_cars');

% アルゴリズムセクションの「新しいROIラベルの定義」で「car」をRectangleとして作る
%  各画像で車両をドラッグで囲む
% 「ラベルをエクスポート」の「ワークスペースへ」を選択
% 「エクスポート対象の変数名」をpositiveInstances、
% 「エクスポート形式」をtable、としMATLABのワークスペースへ

%% Neg画像のフォルダの指定
negFolder = 'I5_02_neg'
winopen(negFolder);     % フォルダーを開いて画像を確認（実際は数百枚以上の画像を使用）

%% 学習の実行 (学習結果が、XML形式のファイルで生成される)
%     分類器モデルファイル：  carDetector.xml  が生成される
%     実際はもっと多くの画像で学習
trainCascadeObjectDetector('carDetector.xml', positiveInstances, negFolder);
        
%% 未知の画像の読込み
I = imread('I5_02_IMG_5959_2a.jpg');
figure; imshow(I);

%% 物体認識オブジェクトの定義、実行 [２行のMATLABコード]
%    ここでは、あらかじめ学習・生成した分類器モデルファイル I5_02_carDetector_20151015Bb.xml を使用
detector = vision.CascadeObjectDetector('I5_02_carDetector_20151015Bb.xml');
cars1 = step(detector, I)

%% 検出された車の位置に、四角い枠とテキストを追加
I2 = insertObjectAnnotation(I, 'rectangle', cars1, [1:size(cars1,1)], 'FontSize',24, 'LineWidth', 4);
imshow(I2);shg;

%% 別の画像の読込み %%%%%%%%%%%%%%%%%%%%%%%%
I = imread('I5_02_DSC_3317a5.JPG');
figure; imshow(I);

%% 物体検出実行･結果の表示
cars2 = step(detector, I)
I2 = insertObjectAnnotation(I, 'rectangle', cars2, [1:size(cars2,1)], 'FontSize',24, 'LineWidth', 12, 'Color','green');
imshow(I2);shg;

%% ツールで検出結果の修正

% イメージラベラーに読み込むためのgroundTruthオブジェクトを生成する
imageFilenames = {[pwd, '\I5_02_IMG_5959_2a.jpg']; [pwd, '\I5_02_DSC_3317a5.jpg']};
dataSource = groundTruthDataSource(imageFilenames);
Cars = {cars1; cars2};
labelDefs = table({'car'},labelType('Rectangle'),'VariableNames',{'Name','Type'});
labelData = table(Cars,'VariableNames',labelDefs.Name);
gTruth = groundTruth(dataSource,labelDefs,labelData);

% 「ラベルをインポート」→「ワークスペースから」でgTruthをインポート
imageLabeler(imageDatastore(imageFilenames));

%% 任意の半自動アルゴリズムの追加
imageLabeler('I5_02_cars');

% アルゴリズムセクションの「新しいROIラベルの定義」で「car」をRectangleとして作る
% 「アルゴリズムの追加」から「アルゴリズムのインポート」を選択
% 「I5_02_CarDetection.m」を選択する
% アルゴリズムの選択一覧に「車検出器」が追加されるので選択し、「自動化」をクリック
% 「実行」を押して半自動ラベリングを実施する

%%
release(detector);

%% 終了

%%
% Copyright 2018 The MathWorks, Inc.