%% 画像の修復（インペインティング・不要物の除去）

%% 画像読み込みと可視化
I = imread('coloredChips.png');
figure
imshow(I,[])

%% 修復箇所を円で指定
h = drawcircle('Center',[130,42],'Radius',40);
numRegion = 6;
roiCenter = [130 42;433 78;208 108;334 124;434 167;273 58];
roiRadius = [40 50 40 40 40 30];
roi = cell([numRegion,1]);
for i = 1:numRegion
    c = roiCenter(i,:);
    r = roiRadius(i);
    h = drawcircle('Center',c,'Radius',r);
    roi{i} = h;
end

%% createMask関数で指定したROIのマスクを生成
mask = zeros(size(I,1),size(I,2));
for i = 1:numRegion
    newmask = createMask(roi{i});
    mask = xor(mask,newmask);
end
% 可視化
montage({I,mask});
title('修復前画像 vs 修復箇所のマスク画像');

%% 該当箇所の画像修復
J = inpaintCoherent(I,mask,'SmoothingFactor',0.5,'Radius',1);
montage({I,J});
title('修復前画像 vs 修復後画像');

%% 
% Copyright 2019 The MathWorks, Inc.