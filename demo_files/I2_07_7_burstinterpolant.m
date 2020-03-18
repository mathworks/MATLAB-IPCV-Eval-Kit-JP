%% 連射画像から高解像度画像生成(超解像)

%% 低解像度の連射画像を読み込み、可視化
setDir = fullfile(toolboxdir('images'),'imdata','notebook');
imds = imageDatastore(setDir,'FileExtensions',{'.png'});
montage(imds)
title('Set of Low-Resolution Burst Mode Images')

%% ブレを除去するために画像の位置合わせ
imdsTransformed = transform(imds,@(x) rgb2lightness(x));
refImg = read(imdsTransformed);
[optimizer,metric] = imregconfig('monomodal');
numImages = numpartitions(imds);
tforms = repmat(affine2d(),numImages-1,1);
idx = 1;
while hasdata(imdsTransformed)
    movingImg = read(imdsTransformed);
    tforms(idx) = imregtform(refImg,movingImg,'rigid',optimizer,metric);
    idx = idx + 1;
end

%% 高解像度画像の生成
scale = 4; % 何倍の解像度で出力するか
B = burstinterpolant(imds,tforms,scale);
figure('WindowState','maximized')
imshow(B)
title ('High-Resolution Image')

%% 入力画像サイズと出力画像サイズを比較
Img = read(imds);
inputDim = [size(Img,1) size(Img,2)]
outputDim = [size(B,1) size(B,2)]

%% 
% Copyright 2019 The MathWorks, Inc.