clear all;clc;close all;imtool close all

%% 曲面への回帰
%   画像の読込み･テスト
G = imread('I3_06_2_IMG_blockG.jpg');
G = im2double(G);
figure;imshow(G,[]);

%% 表面プロット
figure;surf(double(G));shading interp;

%% 中心部を取り除く
s = G;
s(120:240, 70:190) = NaN;
figure;surf(double(s));shading interp;

%% 処理速度向上のため、データ点の間引き (NaNの代入)
mask = true(size(s));
mask([1:20:end], [1:20:end]) = false;
s(mask) = NaN;

%% データの準備：NaNを除去し、xData,yData,zDataのベクトルの形へ変換
[xData, yData, zData] = prepareSurfaceData([1:size(s,1)], [1:size(s,2)], s);

%% GUIツールで行うとき
%cftool  % X・Y・Zデータ => xData・yData・zDataと指定、多項式を選択、xとyの次数を４次へ
%        % 近似プルダウンメニュー => "ワークスペースへ保存"を選択
%        % "OK" => fittedmodelの名前でワークスペースへ保存される

%% コマンドで行うとき
% 近似タイプとオプションを設定
ft = fittype( 'poly44' );
% モデルをデータに近似します。
fittedmodel = fit( [xData, yData], zData, ft)

%% 近似結果をプロットします。(間引きした x・y 点に対し)
figure( 'Name', '近似');
% plots "z versus x and y" and plots "sfit over the range of x and y".
h = plot( fittedmodel, [xData, yData], zData );
legend( h, '近似', 'z vs. x, y', 'Location', 'NorthEast' );
% ラベル Axes
xlabel( 'x' );
ylabel( 'y' );
zlabel( 'z' );
grid on
view( -98.5, 18.0 );

%% 背景の面を、元画像のx・yの細かさ(全ピクセル位置)で計算し、
%   画像データに戻す
[gridX gridY] = meshgrid([1:size(G,2)], [1:size(G,1)]);
backGround1 = fittedmodel(gridX(:), gridY(:));  % 列ベクトル
% 列ベクトルを2次元へ変更
backGround2 = reshape(backGround1, size(G,1), size(G,2));
figure;imshow(backGround2,[]);

%% 背景の局面を差し引き補正後画像を生成
finalImage = G - backGround2;
imtool(finalImage,[0,0.2]);

%% 終了











%% 二値化するだけであれば、適応二値化の使用も可能
BW = imbinarize(G, 'adaptive','ForegroundPolarity','bright','Sensitivity',0.57);
figure; imshow(BW);

%% 回帰した面の最大値ポイントを探す (Optimization Toolboxが必要)
%       極大が複数ある場合には注意
% 目的関数 (変数は一つ）へのハンドル生成
%    複数の引数がある場合は、無名関数を作成し１つのベクトルにまとめる
%    fminconは最小値を探すので、最大値を探したい関数に-1を掛ける
h = @(x) -1 * fittedmodel(x(1), x(2));
%% 検索初期値の設定
x0 = [200; 150];
%% 制約条件：y のみ線形不等式制約  0<= x <=250, 0<= y <=200
l = [  0;   0]
u = [250; 200]
%% 最適化オプションの設定
options = optimset('LargeScale', 'off');
%% 制約条件付の最適化
[x, fval] = fmincon(h, x0, [], [], [], [], l, u, [], options)

%%



%% (参考) 曲面回帰用テスト画像の作成用スクリプト %%%%%%
% ファイルから画像読込み・表示

I=imread('rice.png');        % ファイルから画像読込み
figure; imshow(I);           % 画像の表示
figure; surf(double(I));     % 表面プロット
        shading interp;      % 表示を見やすく

Ierode=imerode(I, ones(15));     % 収縮処理による米粒の消去
figure;imshow(Ierode);
figure; ...
surf(double(Ierode));shading interp;     % 背景表面プロット

Fave = fspecial('average', 30);
Iave = imfilter(Ierode,Fave,'replicate');
figure;imshow(Iave,[]);
a = Iave*2;

b = imread('coins.png');
imtool(b)
c = (b(177:246, 86:155)-72)/4;
d = imresize(c,1.7);
figure;imshow(d);

a(121:239, 71:189) = a(121:239, 71:189) + d;
figure;imshow(a,[]);
figure;surf(double(a));shading interp;
imwrite(a, 'IMG_blockG.jpg');

%%

% Copyright 2014 The MathWorks, Inc.


