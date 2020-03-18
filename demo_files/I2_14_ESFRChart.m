%% eSFRチャートから空間周波数応答(SFR)をプロット

%% チャート画像読み込み
I = imread('eSFRTestImage.jpg');
figure, imshow(I);

%% 逆ガンマ補正
I_lin = rgb2lin(I);

%% eSFRチャートの生成
chart = esfrChart(I_lin);
figure, displayChart(chart)

%% 各ROIのエッジの先鋭度を計測
sharpnessTable = measureSharpness(chart)

%% 25番目と26番目のSFRをプロット
plotSFR(sharpnessTable,'ROIIndex',[25 26]);

% Copyright 2018 The MathWorks, Inc.