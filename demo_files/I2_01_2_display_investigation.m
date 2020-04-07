%% 各種画像フォーマットの読み込み

%% 複数のフォーマットの自動判別
A=imread('peppers.png');    % 拡張子によりファイル形式自動判定
B=imread('street1.jpg');
C=imread('cameraman.tif');

%% 並べて表示
imshowpair(A,B,'montage');truesize;shg

%% モンタージュ表示
load mri;                   % MATファイルから、データの読込み
montage(D,map);truesize;shg % モンタージュ表示

%% イメージビューアー：各種調査用ツール
imtool(A)              % 画像ビューアー アプリケーション

%% イメージブラウザ：フォルダ内の様々なサイズ・データ型の画像を一覧表示
imageBrowser(fullfile(matlabroot,'toolbox','images','imdata'));

%% ボリュームビューアー
load mri           % 128x128x1x27    画像の取込み
D1 = squeeze(D);   % 128x128x27      27枚のスライス画像
volumeViewer(D1)   % ボリュームビューワーの起動
   % ボリュームの読込み
	 % 立方体にアップサンプリング
	 % 表示： ボリューム <=> スライス平面

%% テクスチャマッピング
load clown                % MATファイルから、画像データ'X'の読込み
figure;imshow(X,map);     % 画像表示
[x,y,z]=cylinder;         % 円柱座標生成
figure;mesh(x,y,z,'edgecolor',[0 0 0]);axis square;  %座標表示
warp(x,y,z,flipud(X),map);axis square;shg  %テクスチャマッピング

%% DICOMブラウザーによるファイルの確認
dicomBrowser(fullfile(matlabroot,'toolbox','images','imdata'))

%% スライスビューワー
sliceViewer(D1);

%% オルソスライスビューワー
orthosliceViewer(D1);

%% 任意の切断面の作成と可視化
point = [73 50 15.5]; % 切断平面上の点
normal = [0 15 20]; % 法線ベクトル
[B,x,y,z] = obliqueslice(D1,point,normal);
surf(x,y,z,B,'EdgeColor','None');

%% 終了

%% 
% Copyright 2018 The MathWorks, Inc.

