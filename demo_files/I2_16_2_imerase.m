%% ランダムな窓による画像範囲の塗りつぶし
%% 画像の読込み
I = imread("peppers.png");
imshow(I)
%% ランダムな窓の生成
rect = randomWindow2d(size(I),[50 100]);
%% 窓範囲の塗りつぶし
J = imerase(I,rect);
%% 描画
imshow(J)
%% 
% Copyright 2021 The MathWorks, Inc.