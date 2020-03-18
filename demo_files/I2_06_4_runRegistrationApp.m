%% 画像の読込み
I = imread('mri.tif');

%% 画像の回転
J = imrotate(I,-30);

%% 並べて表示
figure; imshowpair(I, J, 'montage');

%% レジストレーション推定を起動
registrationEstimator(J, I)


% Copyright 2014 The MathWorks, Inc.