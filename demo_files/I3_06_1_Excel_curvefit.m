clear all;clc;close all;imtool close all

%% 画像の読込み
rgb=imread('I3_06_1_color_chart8.jpg');
figure;imshow(rgb);

%% グリッド分割
%[x y] = getpts        % マウスで24枚の各パネル中心近辺をクリック (左上から右へ)
                      % 指定後、リターンキー

% コマンドでx, yを生成する
[y,x] = meshgrid(size(rgb,1)/8:size(rgb,1)/4:size(rgb,1),...
    size(rgb,2)/12:size(rgb,2)/6:size(rgb,2));
x = x(:);
y = y(:);
hold on;
plot(x,y,'o-');

%% マウスで各パネル位置を指定し、R(赤)G(緑)B(青)値 を取得(セクション実行)
Col = uint32(x);
Row = uint32(y);
% (Row, Col, R/G/B) を線形インデックスへ変換 
r_ind = sub2ind(size(rgb), Row, Col, repmat(uint32(1),24,1));
g_ind = sub2ind(size(rgb), Row, Col, repmat(uint32(2),24,1));
b_ind = sub2ind(size(rgb), Row, Col, repmat(uint32(3),24,1));
rgb = double(rgb);
% RGB値を個別のベクトルへ格納
r_camera = rgb(r_ind)
g_camera = rgb(g_ind)
b_camera = rgb(b_ind)

%% EXCELリファレンス R データ読み込み (I3_06_1_color_checker_ref.xls)
% winopen('I3_06_1_color_checker_ref.xls');
%もしくは、I3_06_1_color_checker_ref.xlsを右クリックして、"MATLABの外部で開く"
% 生成済みのimportfile関数を使う
rgb_ref = importfile('I3_06_1_color_checker_ref.xls');
rgb_ref = rgb_ref(:,4:6);

r_ref = rgb_ref(:,1);
cftool;      %曲線近似 GUIツール（Curve Fitting Toolbox)が起動される
             % cftool内の設定：Xデータにr_camera、Yデータにr_ref
             %                 多項式を選択、次数は２次を選択
             %                 近似メニュー -> ワークスペースに保存 -> OK  で、
             %                 近似をMATLABオブジェクトとして保存 (fittedmodel)

%% ワークスペースに保存された結果を確認
if exist('fittedmodel','var')
    fittedmodel
end

%% 緑、青に対しては、コマンドラインで近似多項式を自動生成・表示
if exist('fittedmodel','var')
    curveRed   = fittedmodel;
else
    curveRed = fit(r_camera, rgb_ref(:,1),'poly2');      % 赤のフィッティングををコマンドラインで行うとき
end
curveGreen = fit(g_camera, rgb_ref(:,2),'poly2');
curveBlue  = fit(b_camera, rgb_ref(:,3),'poly2');

%% 得られたトーンマッピング補正曲線により画像の色補正
rgb_op(:,:,1) = reshape(  curveRed(rgb(:,:,1)), size(rgb(:,:,1)));
rgb_op(:,:,2) = reshape(curveGreen(rgb(:,:,2)), size(rgb(:,:,1)));
rgb_op(:,:,3) = reshape( curveBlue(rgb(:,:,3)), size(rgb(:,:,1)));

%% 元画像(左)と、補正した画像(右)の表示
figure; imshowpair(uint8(rgb), uint8(rgb_op), 'montage');

%% 終了









%% Spreadsheet Link EX が無い場合は、下記を実行
% open('I3_06_1_color_checker_ref.xls');
%     上記コマンドを実行後、左上で、インポートするMATLAB変数の型として、"行列"を選択
%     テーブルデータ部分R,G,Bの数字部分(3列分)・2行～25行目を選択し、
%     インポートボタンをクリック => colorcheckrefという変数名でワークスペースにインポートされる
% rgb_ref = colorcheckerref;       % colorcheckref を rgb_ref という変数名へ


% Copyright 2014 The MathWorks, Inc.
