%% 色同士の距離計算
%% テスト画像の読み込み
I1 = imread('peppers.png');
%% 色を少し変える(局所コントラスト強調)
I2 = localcontrast(I1);
%% 色の距離計算
dE1 = deltaE(I1,I2); % CIE76に基づく色の差
dE2 = imcolordiff(I1,I2); % CIE94もしくはCIE2000に基づく距離
%% 結果の表示
imshow([dE1 dE2],[]);
%%
% Copyright 2020 The MathWorks, Inc.