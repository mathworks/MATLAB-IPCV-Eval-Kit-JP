%% 関心領域(ROI)の指定と操作
clear;clc;close all;imtool close all

%% 画像読み込み
figure
im = imread('peppers.png');
imshow(im)

%% さまざまなROI指定
h1 = drawellipse('Center',[127 174],'SemiAxes',[56 24],'RotationAngle',27);
h2 = drawcircle('Center',[152 278],'Radius',30,'Color','red');
h3 = drawfreehand('Position',[86 278;50 262;16 270;5 306;19 340;47 357;80 343;97 312],'Color','yellow');
h5 = drawline('Position',[235 226; 268 237],'Color','green');
h6 = drawpoint('Position',[334 225],'Color','magenta');
h7 = drawpolygon('Position',[448 227;419 308; 509 305],'Color','cyan');
h8 = drawpolyline('Position',[101 383;103 306;406 293],'Color','blue');
h9 = drawrectangle('Position',[185 78 79 54],'Color','white');
shg;

%% アシスト付きのフリーハンドで適当な領域を囲む
h = drawassisted();

%% マスク生成
bw = createMask(h);
figure, imshow(bw);

%% 生成したマスクをアルファマスクとしてガイドフィルターをかける
alphamat = imguidedfilter(single(bw),im,'DegreeOfSmoothing',2);
figure, imshow(alphamat);

%% 適用対象の画像を読み込み、リサイズ
target = imread('fabric.png');
alphamat = imresize(alphamat,[size(target,1),size(target,2)]);
im = imresize(im, [size(target,1), size(target,2)]);
figure, imshowpair(im,target,'montage');

%% アルファブレンド
fused = single(im).*alphamat + (1-alphamat).*single(target);
fused = uint8(fused);
figure, imshow(fused); shg;

%% マスク画像の事前定義
h = 150;  % 生成するマスクの高さ
w = 250;  % 生成するマスクの幅
BW = false(h,w);
figure, imshow(BW);

%% drawpolygonでROI指定
x = [116 194 157 112 117];
y = [ 34  72 105  99  34];
hPolygon = drawpolygon('Position',[x' y']);
shg;

%% roipoly()でマスク生成
BW = roipoly(h, w, x, y);
figure; imshow(BW);

%% poly2mask()でマスク生成
BW = poly2mask(x, y, h, w);
figure; imshow(BW);

%% 楕円形のROI指定
BW = false(150, 250);          % 生成するマスクと同じサイズ
figure; h_im = imshow(BW);
position = [55 20 150 100];     % [xmin ymin width height]
e = drawellipse(gca, 'Center',position(1:2)+position(3:4)/2,...
    'SemiAxes',position(3:4)/2);
shg;

%% 楕円形のROIからマスク生成
BW = createMask(e, h_im);
figure, imshow(BW);

%% 3Dのキューボイド(直方体)でのROI指定
load seamount
figure;
hScatter = scatter3(x,y,z);
hCuboid = drawcuboid(hScatter);

%%
% Copyright 2018 The MathWorks, Inc.

