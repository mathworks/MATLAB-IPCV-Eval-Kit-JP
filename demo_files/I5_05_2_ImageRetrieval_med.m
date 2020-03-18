%% Bag-of-Visual-Wordsを用いた類似画像検索
clc;clear;close all;imtool close all;

%% 画像データの準備
%  カテゴリ毎に画像ファイル名を、Image Set クラスへ格納・画像例表示
%              画像のソース： http://www.cdc.gov/dpdx/index.html    (Centers for Disease Control and Prevention)
if ~exist('classifyBloodSmearImages','dir')
    websave('classifyBloodSmearImages.zip','https://jp.mathworks.com/matlabcentral/mlc-downloads/downloads/submissions/66881/versions/3/download/zip')
    unzip('classifyBloodSmearImages.zip');
end
imgFolder = 'classifyBloodSmearImages\BloodSmearImages';              % 画像へのパスの指定

%% 画像データの読み込み
% フォルダを指定することで、画像ファイル名をImage Set クラスへ格納 (48枚)
%         画像のソース： http://www.cdc.gov/dpdx/index.html    (Centers for Disease Control and Prevention)
bImageDS = imageDatastore(imgFolder,...
    'IncludeSubfolders',true,...
    'FileExtensions',{'.jpg','.tif','.png'})   % 48枚のデータ
% 表示
figure;montage([bImageDS.Files], 'Size',[6 8]); truesize;

%% Visual Words (局所的な模様)の集合を、生成（デフォルト設定：500個）
%   全カテゴリーに対し、縦横それぞれ8ピクセル間隔のグリッド上の点で、各[32 64 96 128]の4つの領域サイズで特徴量を抽出
%   ワード数 2000個に、K-meansでグループ化
% Parallel Computing Toolbox オプションあれば、並列計算も可能  (設定メニュー内のComputer Vision System Toolbox設定内で設定)
% カスタムの特徴量抽出関数の指定も可能 (R2015a)
%    load('I5_05_Parasitology_img\I5_05_2_bag_med.mat');      % あらかじめ生成したものを使う場合
bBag = bagOfFeatures(bImageDS, 'VocabularySize', 2000, 'Upright',false)

%% 全ての画像に、検索用のインデックスを付ける
% 各画像から特徴量を抽出し、VisualWordsに対応づける:  invertedImageIndex クラス
bImageIndex = indexImages(bImageDS, bBag);
%% Visual Wordsが現れた画像の割合
figure; plot(bImageIndex.WordFrequency); 
%% 出現頻度の小さなものから順に並べる
plot(sort(bImageIndex.WordFrequency)); shg;
%% どの画像にも含まれ区別に役に立たないものは除く
bImageIndex.WordFrequencyRange = [0.01 0.85]    %default:[0.01 0.9]

%% 類似画像の検索 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
queryImage = readimage(bImageDS, 19);   % 検索対象画像の読込み
figure; imshow(queryImage);         % 画像の表示

%% Visual Wordsのヒストグラムを表示
figure; histogram(bImageIndex.ImageWords(19).WordIndex, [1:bBag.VocabularySize])

%% スコアを付け、似ているもの上位16個の表示
[imageIDs, scores] = retrieveImages(queryImage, bImageIndex);

% 結果の表示
for i = 1:9      % 上位9個の表示
  I  = readimage(bImageDS, imageIDs(i));            % 画像の読込み
  Ir1(:,:,:,i) = insertText(I, [1 1], num2str(scores(i)), 'FontSize',32); % 4次元方向につなげる
end
figure; montage(Ir1); truesize;


%% 別の画像の検索 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
queryImage = readimage(bImageDS, 48);   % 検索対象画像
figure; imshow(queryImage);

%% 似ているもの上位9個の抽出・表示
[imageIDs, scores] = retrieveImages(queryImage, bImageIndex);
% 結果の表示
for i = 1:9
  I  = readimage(bImageDS, imageIDs(i));            % 画像の読込み
  Ir2(:,:,:,i) = insertText(I, [1 1], num2str(scores(i)), 'FontSize',32); % 4次元方向につなげる
end
figure; montage(Ir2); truesize;


%% Copyright 2015 The MathWorks, Inc.
