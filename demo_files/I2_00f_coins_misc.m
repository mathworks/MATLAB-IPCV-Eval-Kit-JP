clear;clc;close all;imtool close all

%% 物体の定量評価（面積･中心点･直径･周囲長）
I = imread('coins.png');        % 画像の読込
figure; imshow(I);              % 表示

figure; imhist(I);              % ヒストグラム表示
Ibw = I>100;                    % 白黒の画像へ変換
figure; imshow(Ibw);            % 表示
Ibw = I>90;                     % 対話的探索
figure; imshow(Ibw);            % 表示

Ibwf = imfill(Ibw, 'holes');    % 穴を埋める
figure; imshow(Ibwf);           % 表示

Ibwc = bwareaopen(Ibwf, 10);    % ごみの除去  (10ピクセル以下のもの)
figure; imshow(Ibwc);           % 表示        [対話的な探索]

%% 各領域の面積・中心点・直径・周囲長を求める
stats = regionprops('table', Ibwc, 'Area', 'Centroid', 'MajorAxisLength', 'Perimeter')   % struct/table

areas = stats.Area           % 各々の面積

mean(areas)                     % 面積の平均

figure;hist(areas);             % 面積のヒストグラム表示

figure;imshow(I);improfile     % 線分に沿ったピクセル値：2点をマウス右クリックで指定しリターン

figure; surf(double(I));shading interp;  % 3次元表示(回転可)：ツールメニュー内の"3次元回転"
%%




%%   物体定量評価の結果を画像上に書込み
I1 = insertMarker(I, stats.Centroid, 'star', 'Color','red');
I2 = insertText(I1, stats.Centroid,  cellstr(num2str(areas)), 'BoxOpacity',0, 'FontSize',10);
I3 = insertText(I2, [160, 220], ['# of coins: ' num2str(size(stats, 1))], 'FontSize',16);
figure; imshow(I3);
hold on;
visboundaries(Ibwc, 'Color','g');
hold off;

%% 終了





%% エッジ検出
I = imread([matlabroot '\toolbox\coder\codegendemos\coderdemo_edge_detection\hello.jpg']);
figure;imshow(I);
G = rgb2gray(I);
figure;imshow(G);
Gcanny = edge(G,'canny',0.18);        % エッジ検出：キャニー法
figure;imshow(Gcanny);


%% 円の検出
RGB = imread('tape.png');        % セロテープの画像
figure;imshow(RGB);
[center, radius] = imfindcircles(RGB,[60 100],'Sensitivity',0.9)  %円の検出
viscircles(center,radius);      % 円の表示
hold on; plot(center(:,1),center(:,2),'yx','LineWidth',4); hold off;


%% 平均化フィルター処理
Fave=fspecial('average');           % フィルター係数生成
Iave=imfilter(I, Fave);             % フィルター処理
I=[I Iave];                         % 右横に別の画像を拡張
figure; imshow(I);                  % 表示

%% 鮮明化処理
Ish=imsharpen(Iave, 'Amount', 3);        % フィルター処理、強度
figure; imshowpair(Iave, Ish, 'montage'); % 横並び可視化

fspecial('average')
fspecial('average', 5)
edit fspecial      % fspecial関数の実装表示 or 関数選んでF4
doc                % 充実したドキュメント
%% 終了












%% [参考]
% 閾値を自動的に求める関数
Th = graythresh(I)              % 大津法を使いて画像の二値化用閾値を求める
Ibw = im2bw(I, Th);             % 求めた閾値を用いて画像の二値化
figure; imshow(Ibw);            % 画像の表示



doc                             % ドキュメントを開く
edit imfill                     % M言語で書かれている関数も多いので実装を御確認いただけます
edit bwareaopen


% Copyright 2014 The MathWorks, Inc.
