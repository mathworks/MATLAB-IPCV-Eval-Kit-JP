%% RGB色空間の補正

%% 画像読み込み
A = imread('foosballraw.tiff');

%% デモザイク & ゲイン調整
% RGGBのベイヤーパターンからRGB補間)
A = demosaic(A,'rggb');
A = 3*A; % ゲイン調整
A_sRGB = lin2rgb(A);
figure
imshow(A_sRGB,'InitialMagnification',25)
title('Original Image')

%% チェッカーボードのグレイの位置を指定
x = 1510;
y = 1250;
hold on;
plot(x,y,'ro');
light_color = [A(y,x,1) A(y,x,2) A(y,x,3)]

%% 色調自動補正
B = chromadapt(A,light_color,'ColorSpace','linear-rgb');
B_sRGB = lin2rgb(B);
figure
imshow(B_sRGB,'InitialMagnification',25)
title('White-Balanced Image')

%% 補正後の色の確認(RGBが同じ強度になっている)
patch_color = [B(y,x,1) B(y,x,2) B(y,x,3)]

%% 霧の除去
% 
%% 画像読み込み
A = imread('foggysf2.jpg');
figure, imshow(A);

%% 霧の除去
B = imreducehaze(A, 0.9, 'method', 'approxdcp');
figure, imshow(B);

%% 並べて表示
figure, imshowpair(A, B, 'montage')

%%
% Copyright 2017 The MathWorks, Inc.