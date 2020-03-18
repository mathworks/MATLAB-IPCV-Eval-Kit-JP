% マルチページTIFF ファイル の読込み

%% 画像ファイルの情報の取得
info = imfinfo('corn.tif')

%% 一番目の画像の読込み
[I, map] = imread('corn.tif', 'Index',1, 'Info', info);
%% 表示
imtool(I, map)

%% 二番目の画像の読込み
[I, map] = imread('corn.tif', 'Index',2, 'Info', info);
imtool(I, map)

%% 二番目の画像の読込み
[I, map] = imread('corn.tif', 'Index',3, 'Info', info);
imtool(I, map)


% Copyright 2018 The MathWorks, Inc.