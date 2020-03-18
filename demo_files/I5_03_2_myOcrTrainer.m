clear;clc;close all;imtool close all

%% 画像の読込み･表示
I = imread('I5_03_2_imgPi.JPG');
figure;imshow(I);

%% 画像の二値化
BW = imbinarize(rgb2gray(I));
figure;imshow(BW);

%% 文字のかすれを取る（白い小さな抜けを埋める）
BW1 = imopen(BW, ones(5));     %収縮=>膨張
imshow(BW1); shg;

%% 文字認識・表示
results = ocr(BW1)
Ir1 = insertObjectAnnotation(I, 'rectangle', results.WordBoundingBoxes, results.Words, 'FontSize',40);
figure; imshow(Ir1);truesize;

%% OCR Trainerで、カスタムフォントを学習（認識したい文字をもれなく学習させる）
ocrTrainer

% New Sessionをクリック
%      学習させる言語データベース名（任意の名前）を指定
%      出力ディレクトリの指定（そのディレクトリがあらかじめ存在する必要あり）
%            学習実行後に自動的に下記の様にファイルが生成される
%                  出力ディレクトリ\<言語データベース名>\tesdata\<言語データベース名>.traineddata
%      Pre-label using OCRをONにして、言語を指定し自動ラベリングさせる（この言語は、Pre-Labelにのみ用いられる）
%      学習用画像(I5_03_2_7segTraining1.png)を指定して、OK （後で追加も可能）：
%                        - 出来るだけ文字部分のみ切り出した画像を使用、
%                        - 各文字10サンプル以上は学習させる
%                        - '0000'や'1111'のような形式だけではなく実際に単語として現れる他の文字との位置関係等も
%                          反映した学習データを用いる
%      自動で二値化され、[CROP Images] メニューに移動
%      文字部分が白（前景）になる
%  *[注]*小数点用に、Min Areaを10まで下げる
%      文字の領域をROIとして指定することで、セグメンテーション結果の改善が可能
%      不適切な画像を、セッションから削除できる
%         Acceptで次へ

% [OCR Trainer] タブ
%      指定した既存OCRデータベースで、ラベリングされる。
%      セグメンテーションされた結果をダブルクリックで、元画像が表示され、セグメンテーションの修正が可能
%      間違ったもののラベルを修正しEnter（複数選択可:Shift・Ctrl）
%      学習に使いたくないものは、Unknown カテゴリーへ分類
%      Settingsで、ラベルに使用するフォントを選択可
%   Train ボタンで、学習    => 学習後、自動的にデータベースが保存され、その保存先が表示される。

% セッションを保存しても、学習用画像データは含まれないので、別途保存が必要

%% 作製したデータベースで、文字認識・結果の表示
%     データベースファイルは、単一のtessdataという名前のフォルダ内に置く
results = ocr(BW1, 'Language', 'I5_03_2_myLang\tessdata\myLang.traineddata')
Ir2 = insertObjectAnnotation(I, 'rectangle', results.WordBoundingBoxes, results.Words, 'FontSize',40);
figure; subplot(2,1,1); imshow(Ir1); title('with original English database', 'FontSize',18);
        subplot(2,1,2); imshow(Ir2); title('with trained database', 'FontSize',18);

%% 終了











%% 漢字でラベリング･学習した言語データを使用した場合
results_J = ocr(BW1, 'Language', 'I5_03_2_myLang\tessdata\myLang_J.traineddata', 'TextLayout','Word')
% 結果の表示
Ir2_J = insertObjectAnnotation(I, 'rectangle', results_J.WordBoundingBoxes, results_J.Words, 'FontSize',30, 'Font','MS Gothic');
figure; subplot(2,1,1); imshow(Ir1  ); title('with original English database', 'FontSize',18);
        subplot(2,1,2); imshow(Ir2_J); title('with trained database', 'FontSize',18);
        
%% Copyright 2016 The MathWorks, Inc.
