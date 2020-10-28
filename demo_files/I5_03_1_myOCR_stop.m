clear;clc;close all;imtool close all

%% 画像の読込み
I = imread('I5_03_1_ocr\IMG_2537_stop.JPG');
figure;imshow(I);

%% グレースケール画像へ変換
G = rgb2gray(I);
figure;imshow(G);

%% モルフォロジー処理で、字の部分のみを残す
G2 = imbothat(G, ones(13));   imshow(G2); %黒い文字を残す：Close - 原画
G3 = imbinarize(G2,graythresh(G2));imshow(G3); %二値化
G4 = imopen(G3, ones(5));     imshow(G4); %細い線を除去
G5 = bwareaopen(G4,200);                  %小さいごみを除去
imshow(G5);
     
%% 文字認識
results = ocr(G5, 'Language','Japanese')

%% 結果を表示
I1 = insertShape(I, 'Rectangle', results.WordBoundingBoxes, 'LineWidth', 3);
figure;imshow(I1);
text(results.WordBoundingBoxes(1), results.WordBoundingBoxes(2)-50, results.Words(1),'FontSize',12,'BackgroundColor',[1 1 0]);


%% 読み上げ (日本語音声合成エンジンは別途入手要)
NET.addAssembly('System.Speech');   %.NETアセンブリの読込み
speak = System.Speech.Synthesis.SpeechSynthesizer;
speak.Volume = 100;
speak.SelectVoice('けいこ');

speak.Speak([results.Words{1} ' して下さい']);


%% 読み上げ (英語音声合成エンジンはWindowsに付属)
NET.addAssembly('System.Speech');   %.NETアセンブリの読込み
speak = System.Speech.Synthesis.SpeechSynthesizer;
speak.Volume = 100;
speak.Speak('stop');


%% 終了











%% 日本語の読み上げには、別途日本語音声合成エンジンが必要
%  英語に関してはWindowsに内臓

%% ocr実行前に、関数内部でOtu法により2値化されています
%G = rgb2gray(I);imtool(im2bw(G,graythresh(G)))

% Copyright 2014 The MathWorks, Inc.
