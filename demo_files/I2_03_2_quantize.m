clear all;clc;close all;imtool close all

%% グレースケール変換 %%%%%%%%
A = imread('I2_03_peppers_low.png');
figure;imshow(A);
%%
Gray = rgb2gray(A);
h=figure;imshow(Gray);

%% コントラスト調整 %%%%%%%%
figure;imhist(Gray);     % 輝度値のヒストグラムを表示
%% コントラスト調整ツールで手動調整
imcontrast(h)
%% 低・高輝度で1%飽和するよう自動調整
Gray1 = imadjust(Gray);
figure;imhist(Gray1);
%% 表示
figure;imshow([Gray Gray1]);shg

%% 量子化 (2値化) %%%%%%%%
I = imread('coins.png');
figure;imshow(I);
%%
figure;imhist(I);        % 輝度値のヒストグラムを表示
%%
BW = I > 100;            % 輝度値 100を閾値に量子化
figure;imshow(BW);
%%
BWf = imfill(BW, 'hole');  % 穴を埋める(モルフォロジー処理)
figure;imshow(BWf);

%% 多値自動量子化 %%%%%%%
I = imread('I2_03_2_circlesBrightDark_clean1.png');
imtool(I);                   % 各領域の値を確認
%%
figure;imhist(I);            % ヒストグラム表示
%%
thresh = multithresh(I,2)     % Otsu法により閾値を計算 (関数の戻値が閾値)
                              % クラス間の分離度を最大にする
seg_I = imquantize(I,thresh); % 得られた閾値により、画素値を量子化(1,2,3)
imtool(seg_I,[]);             % 表示 => 画素値の確認
%%
RGB = label2rgb(seg_I);       % 異なるラベル番号(画素値)を異なる色へ
figure;imshowpair(I,RGB,'montage');  % 画像表示

%% 終了
















%% (参考) 'I2_3_peppers_low.png' ファイルの生成
A=imread('peppers.png');
aa=A*0.5 + 70;
imwrite(aa,'I2_3_peppers_low.png')

%% (参考) 'circlesBrightDark_clean1.png' の生成
I = imread('circlesBrightDark.png');
B1= (I > 10) & (I < 220);
I(B1) = 50;

B1= (I < 40)
I(B1) = 10;

B1= (I > 220)
I(B1) = 230;

imshow(I)
imhist(I)

r = randn(512)*2;    % 乱数の生成
max(r(:))
min(r(:))

I1 = int16(I)+int16(r);
min(I1(:))
max(I1(:))
I2 = uint8(I1)

imhist(I2)
figure;imshow(I2)

imwrite(I2, 'I2_3_2_circlesBrightDark_clean1.png');


% Copyright 2014 The MathWorks, Inc.
