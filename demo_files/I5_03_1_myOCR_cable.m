clear;clc;close all;imtool close all

%% 画像の読込み･表示
G = imread('I5_03_1_ocr\IMG_2517_cable.jpg');
figure;imshow(G);

%% 文字のかすれを取る（白い小さな部分の除去）
G1 = imopen(G, ones(6));     %収縮=>膨張
figure;imshow(G1);

%% ボトムハット処理で、字の部分のみを残す
G2 = imbothat(G1, ones(18));   %Close - 原画
figure;imshow(G2);

%% 文字認識
results = ocr(G2)

%% 各検出領域の確度を表示
Ic = insertObjectAnnotation(G2, 'rectangle', results.WordBoundingBoxes, results.WordConfidences, 'FontSize', 30);
imtool(Ic);

%% 確度の高い文字のみを表示
valid = (results.WordConfidences > 0.6) & ~strcmp(results.Words, '')   %確度が0.5以上のものを取出す。改行の検出結果も除去
Ir = insertObjectAnnotation(G, 'rectangle', results.WordBoundingBoxes(valid,:), results.Words(valid), 'FontSize',40);
imtool(Ir);

%%












%% 音声による読み上げ
NET.addAssembly('System.Speech');   %.NETアセンブリの読込み
speak = System.Speech.Synthesis.SpeechSynthesizer; speak.Volume = 100;
speak.SelectVoice('けいこ');
words = results.Words(valid);
speak.Speak(['最初の番号は、' words{1}]);



%% 音声による読み上げ (英語音声合成エンジンはWindowsに付属)
NET.addAssembly('System.Speech');   %.NETアセンブリの読込み
speak = System.Speech.Synthesis.SpeechSynthesizer;
speak.Volume = 100;
words = results.Words(valid);
speak.Speak(['The first number is' words{1}]);



%% 終了







%% 日本語の読み上げには、別途日本語音声合成エンジンが必要
%  英語に関してはWindowsに内臓

%% 画像の読込み･表示
G = imread('I5_3_ocr\IMG_2517_cable.jpg');
figure;imshow(G);
%% 文字認識（ROIを使用）
results2 = ocr(G, [2020 900 790 380])
results2 = ocr(G, [1900 900 890 380])
results2 = ocr(G, [1800 900 1000 380])
results2 = ocr(G, [1990 900 800 380])
%% 各検出領域の確度を表示
Ic2 = insertObjectAnnotation(G, 'rectangle', results2.WordBoundingBoxes, results2.WordConfidences, 'FontSize', 30);
imtool(Ic2);

%% 結果の表示
Ir2 = insertObjectAnnotation(G, 'rectangle', results2.WordBoundingBoxes, results2.Words, 'FontSize',40);
imtool(Ir2);

%% 終了




%% すべての文字を読み上げる場合
speak.Speak('番号は');
words = regexprep(results.Words(valid), '$', ' ','emptymatch')   % 文字列の最後にスペースを挿入
speak.Speak([words{:}]);

%% 音声による読み上げ (English)
NET.addAssembly('System.Speech');   %.NETアセンブリの読込み
speak = System.Speech.Synthesis.SpeechSynthesizer; speak.Volume = 100;
words = results.Words(valid);
speak.Speak(words{1});

%% 別の処理ステップ
G1 = imerode(G, ones(4));     %白い部分を削り、字を太くくっきりさせる
G2 = imbothat(G1, ones(19));  %ボトムハット処理で字の部分のみ取出す
results = ocr(G2)             %OCR

% Copyright 2014 The MathWorks, Inc.
