%% 各種画像フォーマットの読み込み %%%%%%%%%%%%%%%
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
imageBrowser([matlabroot, '\toolbox\images\imdata\']);

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
dicomBrowser(fullfile(matlabroot,'toolbox/images/imdata'))

%% 終了















% imshow(C);shg     % imtoolの機能の一部を使うことも可能
% imcrop            % トリミング：領域選択後、Wクリック
% [x,y]=getpts      % 点の指定：クリックで指定、Wクリックで終了
% h=imrect            % 四角形の領域をマウスで指定
% position=wait(h)  % 四角形領域をマウスでダブルクリックで、[xmin ymin width height] を返す。
% C1 = imcrop(C, position);  % トリミング
% figure;imshow(C1);  % 表示


%% 
% Copyright 2018 The MathWorks, Inc.

