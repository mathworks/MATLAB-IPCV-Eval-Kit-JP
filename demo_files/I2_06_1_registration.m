%% 輝度ベースの自動レジストレーション（位置合せ）
clear all; close all; clc;

%% 2つの画像の読込・表示
orig  = dicomread('knee1.dcm');
moving = dicomread('knee2.dcm');
figure; imshowpair(moving, orig, 'montage');    %並べて表示
%%
imshowpair(moving, orig);shg;                   %重ねて表示

%% 輝度ベースのレジストレーション実行・表示  （変換行列が必要な場合は、imregtform を使用）
[optimizer,metric] = imregconfig('multimodal'); % パラメタ設定 (別々のデバイス：異なる輝度範囲)
optimizer.MaximumIterations = 150;           % 反復回数
optimizer.InitialRadius = 0.002;             % 初期検索範囲

Registered = imregister(moving, orig, 'affine', optimizer, metric);      %アフィン変換：拡大縮小・平行移動・回転
figure, imshowpair(Registered, orig)            % 表示

%% [終了]
% Copyright 2014 The MathWorks, Inc.




















%% シンプルな図形1
G1 = zeros([16,20], 'uint8')
G1(5, 3:12) = [10:10:100]
G2 = zeros([16,20], 'uint8')
G2(5, 6:15) = [10:10:100]

[optimizer,metric] = imregconfig('monomodal'); % パラメタ設定
tform = imregtform(G2, G1, 'translation', optimizer, metric)
tform.T
G3 = imwarp(G2, tform, 'OutputView',imref2d(size(G1)));
% 結果の可視化
G1(5,:)
G2(5,:)
G3(3:7,:)

%% シンプルな図形2 (サブピクセル単位のレジストレーション)
G1 = zeros([16,20], 'uint8')
G1(5, 3:7)  = [10:10:50]
G1(5, 8:11) = [40:-10:10]
G2 = zeros([16,20], 'uint8')
G2(5, 6:10) = [5:10:45]
G2(5, 11:15) = [45:-10:5]

[optimizer,metric] = imregconfig('monomodal'); % パラメタ設定
tform = imregtform(G2, G1, 'translation', optimizer, metric, 'PyramidLevels',1)
tform.T
G3 = imwarp(G2, tform, 'OutputView',imref2d(size(G1)));
% 結果の可視化
G1(5,:)
G2(5,:)
G3(3:7,:)
%% 
