clear;clc;close all;imtool close all

%% 画像の読込み・表示
I = imread('I5_03_1_ocr\IMG_2521_sign40.JPG');
figure;imshow(I);

%% 赤い領域を抽出
HSV = rgb2hsv(I);
areaRed = ((HSV(:,:,1) >= 0.9 ) | (HSV(:,:,1) <= 0.05 )) & ...
          (HSV(:,:,2) >= 0.8 );
figure;imshow(areaRed);

%% 小さなゴミを除去
areaRed1 = bwareaopen(areaRed,500);
figure;imshow(areaRed1);

%% 赤に囲まれている部分を抽出
areaRedFilled = imfill(areaRed1,'holes');   %赤で囲まれている部分を埋める
G = rgb2gray(I);
G(~areaRedFilled)=255;     %赤で囲まれている部分を抽出
figure;imshow(G); 

%% 赤い部分も除去
areaRed2 = imdilate(areaRed1,ones(11));   % 赤い部分を少しだけ膨張
G(areaRed2)=255;                          % 赤色部分を除去
figure;imshow(G); 

%% 文字認識
results = ocr(G)

%% 文字の表示
Ir = insertObjectAnnotation(I, 'rectangle', results.WordBoundingBoxes, results.Words, 'FontSize',50);
imtool(Ir);

%% 文章作成
sentense = ['制限速度は、' results.Words{1} 'キロです。']    % 日本語読上げの文章
%sentense = ['Speed limit is ' results.Words{1}]             % 英語読上げの文章

%% 読み上げ (日本語音声合成エンジンは別途入手要)
NET.addAssembly('System.Speech');   %.NETアセンブリの読込み
speak = System.Speech.Synthesis.SpeechSynthesizer; speak.Volume = 100;
speak.SelectVoice('けいこ');
speak.Speak(sentense);

%% 読み上げ (英語音声合成エンジンはWindowsに付属)
NET.addAssembly('System.Speech');   %.NETアセンブリの読込み
speak = System.Speech.Synthesis.SpeechSynthesizer; speak.Volume = 100;
speak.SelectVoice('Microsoft Anna')
speak.Speak(sentense);


%% 終了









%% 日本語の読み上げには、別途日本語音声合成エンジンが必要
%  英語に関してはWindowsに内臓

%% 各検出領域の確度を表示する場合
%Ic = insertObjectAnnotation(G, 'rectangle', results.WordBoundingBoxes, results.WordConfidences, 'FontSize', 30);
%imtool(Ic);

%% ocr実行前に、関数内部でOtu法により2値化されています
%G = rgb2gray(I);imtool(im2bw(G,graythresh(G)))

% Copyright 2014 The MathWorks, Inc.
