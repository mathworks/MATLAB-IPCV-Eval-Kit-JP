clear all;clc;close all;imtool close all

%% エッジ検出 %%%%%%%%
I = imread('coins.png');        % 画像の読込
figure; imshow(I);              % 表示
%%
BWsobel   = edge(I,'sobel');               % ソーベル法
figure;imshow(BWsobel  ); title('sobel');
%%
BWcanny = edge(I,'canny');                 % キャニー法
figure;imshow(BWcanny); title('canny');

%% コーナー検出 %%%%%%%%
I = checkerboard(50,2,2);     % テスト画像の生成
figure;imshow(I);
%%
C = detectHarrisFeatures(I);   % Harrisコーナー検出器
%C = detectMinEigenFeatures(I); % 最小固有値法
I1 = insertMarker(I,C,'circle','Size',5,'Color','magenta');
imshow(I1);shg;

%% セロテープ：ハフ変換による円の検出 %%%%%%%%
RGB = imread('tape.png');
figure;imshow(RGB);
%% 円の検出
[center, radius] = imfindcircles(RGB,[60 100],'Sensitivity',0.9)      %半径60~100
%% 円と中心点の表示
viscircles(center,radius);                  % 円を描画
hold on; plot(center(:,1),center(:,2),'yx','LineWidth',4); hold off; % 中心点表示

%% 終了











%% 円検出 の追加のデモ
G = imread('I2_09_1_circlesBrightDarkSquare.png');  % 画像の読込み
figure;imshow(G);                     % 表示
% 背景より暗い円の検出･赤線で表示
[cDark, rDark] = imfindcircles(G,[30 65],'ObjectPolarity','dark')
viscircles(cDark, rDark,'LineStyle','--');shg;
% 背景より明るい円の検出･青線で表示
[cBright, rBright] = imfindcircles(G,[30 65],'ObjectPolarity','bright','EdgeThreshold',0.2)
viscircles(cBright, rBright,'EdgeColor','b');shg;




%% [参考]
% 円の検出・円と中心点の表示後、半径値を画像上に書込む
message = sprintf('The estimated radius is %2.1f pixels', radius);
text(15,300,sprintf('radius : %2.1f', radius), 'Color','y','FontSize',20);

% 円と中心点を画像データに書込む場合
Ir = insertShape(RGB, 'Circle', [center radius], 'Color','red', 'LineWidth',4);
Ir = insertShape(Ir, 'FilledCircle', [center 5], 'Color','yellow', 'Opacity',1);
imtool(Ir);

%% [参考] 円検出のデモ画像の作成スクリプト
G = imread('circlesBrightDark.png');  % 画像の読込み
G1 = insertShape(G,'FilledRectangle',[179,188,90,90],'Color','white','Opacity',1);
G1 = insertShape(G1,'FilledRectangle',[50,335,80,80],'Color','black','Opacity',1);
imwrite(G1, 'I2_09_1_circlesBrightDarkSquare.png')

%%
% Copyright 2014 The MathWorks, Inc.

