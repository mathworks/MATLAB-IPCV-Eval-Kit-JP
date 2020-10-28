%% くっついている種を個別に認識し、個数・面積の計測、面積分布・平均面積の計算
%    初期化
clear;clc;close all;imtool close all

%% イメージの読み込み
I = imread('I2_09_4_6_DSC_1903cr.jpg');
figure;imshow(I);                          % ;がコマンド区切

%% Final画像を確認
figure;imshow(imread('I2_09_4_6_DSC_1903result.jpg'));

%% グレースケールへ変換
G = rgb2gray(I);
imtool(G);

%% 輝度により二値化
figure;imhist(G);
%%
BW = G < 195;
imshow(BW);shg

%% 細かいノイズの除去
BWclean = bwareaopen(BW, 20);
figure;imshow(BWclean);

%% 穴の塗りつぶし
BWfill = imfill(BWclean, 'holes');
figure;imshow(BWfill);

%% 画面端のかけているものを除去
BWclear = imclearborder(BWfill);
figure; imshow(BWclear);

%% 距離変換の実行（2値画像エッジに勾配をつける）
BWclear_b = ~BWclear;
imshow(BWclear_b);shg;         %背景と前景の反転結果
%%
BWdist = bwdist(BWclear_b);
figure;imshow(BWdist,[]);shg;  %距離変換(白い領域までの距離)の結果
%%
BWdist = -BWdist;
imshow(BWdist, []);shg;        %背景と前景の反転結果
%   粒子領域内で、縁(前景)までの距離がその画素位置の値
%   背景領域は、値='0'

%% バックグランドが領域に含まれないように、-Infに指定
BWdist(BWclear_b) = -Inf;         %BWdistで白くなっている背景部分を-Infにする。
imshow(BWdist, []);shg;

%% 一つの粒子が複数に分割されるのを防ぐために、各粒子内極小領域を１つへ
figure;imshow(imregionalmin(BWdist));  %局小部分を白く表示
%%
BWhmin = imhmin(BWdist, 2);            %局小部分を2持ち上げる
figure;imshow(imregionalmin(BWhmin));  %局小部分を再度白く表示

%% ウォーターシェッド変換を行い、極小点毎に領域分割・表示
%figure;surf(double(BWhmin));shading interp; %表面プロット
%
BWshed = watershed(BWhmin);

% 表示
imtool(BWshed,[]);   %領域毎に番号が割り振られているのを確認   
                     %背景は領域1
                     %領域0 は分水嶺(峰)：特定の分水嶺領域に属さない。
BWlabel = label2rgb(BWshed,'jet');
imshow(BWlabel);shg                %領域ごとに別の色で表示 (領域0は、白色)

%% regionprops関数により、各エリア等を計算
stat = regionprops(BWshed, 'Area', 'Centroid')
stat(10)
stat(1) = [];      % 背景からのデータを除去

%% 結果の表示
BWshed(BWshed==1)=0;    % 背景(領域番号1)を領域番号0へ変更
boundaries = bwboundaries(BWshed, 'noholes'); % 各領域の境界を抽出（穴はトレースせず）
figure;imshow(I);
hold on;
for k=1:size(boundaries)
   b = boundaries{k};
   plot(b(:,2),b(:,1),'r','LineWidth',2);
end
hold off

%% 終了















%% 参考 (追加の処理) %%%%%%%%%%%%%%%
%% 粒子の個数
size(stat, 1)
%% 粒子の個々の面積の平均
mean([stat.Area])
%% 粒子の個々の面積
A=[stat.Area]
%% ヒストグラム表示
figure;histogram(A,1700:100:2500);
%% 総面積
sum([stat.Area])

%% 輪郭抽出の別のスクリプト(BWlabelの白い部分(領域番号0)を抽出)
BWperi_t = (BWlabel(:,:,1) == 255) & ...
           (BWlabel(:,:,2) == 255) & ...
           (BWlabel(:,:,3) == 255);
imshow(BWperi_t);shg;
% 見やすくするために輪郭を膨張処理で太く
BWperi = bwmorph(BWperi_t, 'dilate');
figure;imshow(BWperi);
% 輪郭を赤線で上書き
BWfalse = false(size(BWperi));
Iperi = I;                       % 入力画像をコピー
Iperi(cat(3,BWfalse, BWperi, BWfalse)) = 255;
Iperi(cat(3,BWperi,  BWfalse,BWperi )) = 0;
Iperi(cat(3,BWperi, BWfalse, BWfalse)) = 255;
Iperi(cat(3,BWfalse,  BWperi,BWperi )) = 0;
imshow(Iperi);shg;
% 個々の粒子の、中心点と面積を上書き表示
centroids = cat(1,stat.Centroid);  %中心点の座標ベクトルを作成
areas     = cat(1, stat.Area);     %面積ベクトルの作成
Ifinal = insertMarker(Iperi, centroids, 'star', 'Color','green', 'Size',5);  %中心位置に緑の＊マークを記す
Ifinal = insertText(Ifinal, centroids,  cellstr(num2str(areas)), 'BoxOpacity',0, 'FontSize',18); %面積の値を書込み
imshow(Ifinal);shg;

%% Copyright 2013 The MathWorks, Inc.
%    Masa Otobe (masa.otobe@mathworks.co.jp)

% 必要なファイル : DSC_1903cr.jpg, DSC_1903result.jpg
