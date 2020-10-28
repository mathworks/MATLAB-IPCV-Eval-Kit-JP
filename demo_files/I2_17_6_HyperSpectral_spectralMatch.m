%% ハイパースペクトル画像のスペクトルマッチング
clc;clear;close all;imtool close all;rng('default');

%% スペクトルライブラリからの植生シグネチャの抽出
fileroot = matlabshared.supportpkg.getSupportPackageRoot();
filename = fullfile(fileroot,'toolbox','images','supportpackages','hyperspectral','hyperdata',...
               'ECOSTRESSSpectraFiles','vegetation.tree.tsuga.canadensis.vswir.tsca-1-47.ucsb.asd.spectrum.txt');
libData = readEcostressSig(filename);

%% ハイパースペクトルデータの読み込み
hcube = hypercube('paviaU.hdr');

%% スペクトルマッチング
% 画像全体から植生のシグネチャに対する距離を計算
score = spectralMatch(libData, hcube);

figure
imagesc(score)
colorbar

%% 植生マスクを生成
% 植生と考えられる領域の抽出
threshold = 0.3;
bw = score < threshold;
% マスク
Ts = hcube.DataCube .* double(bw);
segmentedDatacube = hypercube(Ts, hcube.Wavelength);

% 可視化
rgbImg = colorize(hcube,'Method','rgb','ContrastStretching',true);
segmentedImg = colorize(segmentedDatacube,'Method','rgb','ContrastStretching',true);
B = imoverlay(rgbImg, bw,'Yellow');

figure;
montage({rgbImg segmentedImg B },'Size', [1 3]);
title(['Original Image | ' 'Segmented Image | ' 'Overlayed Image']);

%% Copyright 2020 The MathWorks, Inc.
