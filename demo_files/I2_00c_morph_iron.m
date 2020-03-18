clear all;clc;close all;imtool close all

%% オリジナル画像のロードと表示
Iorg=imread('I2_00c_iron.tif');
imtool(Iorg);      % コントラスト調整メニューでヒストグラム確認
%title('Original Image','Fontsize',12,'Fontweight','bold')

%% 2値化 (強度レベル180を閾値とする。黒い線を前景に)
I = Iorg<180; 
figure; imshow(I)
title('２値化','Fontsize',12,'Fontweight','bold')

%% 細線化処理(skel)
I = bwmorph(I,'skel','inf');
figure; imshow(I)
title('細線化','Fontsize',12,'Fontweight','bold')

%% 枝線の除去(spur)
I = bwmorph(I,'spur','inf');
figure; imshow(I)
title('枝線の除去','Fontsize',12,'Fontweight','bold')

%% 孤立オブジェクトの除去(clean)
I = bwmorph(I,'clean');
figure; imshow(I)
title('孤立オブジェクトの除去','Fontsize',12,'Fontweight','bold')

%% 反転
Ir=~I;
imshow(Ir);shg;

%% 各領域を固有の番号でラベリング（背景は 0）
L = bwlabel(Ir,4);	% 各領域を固有の番号でラベリング (4連結)
imtool(L);          % 各領域の値を確認

%% ラベル番号毎に色分け
figure; imagesc(L); colormap(jet)
title('ラベリング','Fontsize',12,'Fontweight','bold')

%% イメージの領域解析 アプリケーション

%% 領域プロパティの測定 (面積・中心点(重心))
stats = regionprops(L, 'Area', 'Centroid')

%% 一番目の領域の測定結果
stats(1)

%% 画像上に面積を表示
hold on
for x = 1:length(stats)
	if stats(x).Area > 50	% 50ピクセル以上の領域のみ表示
		xy = stats(x).Centroid;
        plot(xy(1), xy(2), 'r*');  %中心位置に赤の＊マークを記す
		text(xy(1)+4, xy(2), num2str(stats(x).Area));
	end
end
hold off
title('プロパティ算出','Fontsize',12,'Fontweight','bold');shg;

%% 統計処理
A = [stats.Area]     % 求まった各面積
%% 面積の平均
mean(A)
%% ヒストグラム表示
figure;hist(A)

%% 端が切れている領域を削除
L1 = imclearborder(L,4);
figure;imagesc(L1),colormap(jet)

%% 
% Copyright 2014 The MathWorks, Inc.
