%% 非局所平均(Non-local means)フィルタによるノイズ除去

%% 画像を読み込み、ノイズを付加
im = imread('peppers.png');
imn = imnoise(im, 'gaussian', 0, 0.0015);
figure, imshow(imn);

%% 色空間をRGBからL*a*bに変換
iml = rgb2lab(imn);

%% 特定の領域を切り出す
rect = [210, 24, 52, 41];
imcl = imcrop(iml, rect);

%% パッチ内の標準偏差を計算
edist = imcl.^2;
edist = sqrt(sum(edist,3)); % 原点からのユークリッド距離
patchSigma = sqrt(var(edist(:)));

%% スムーシングのパラメータを指定してノイズ除去
imls = imnlmfilt(iml,'DegreeOfSmoothing', 1.5*patchSigma);
ims = lab2rgb(imls,'Out','uint8');
montage({imn, ims});

%%
% Copyright 2018 The MathWorks, Inc.
