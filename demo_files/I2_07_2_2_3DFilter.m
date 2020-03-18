%% MRI画像の3次元ガウシアンフィルタリング
clear; clc; close all;    % 初期化

%% MRI画像の読込み･表示
mri = load('mri');          % 画像の読込み (27枚のMRI断面画像)
D = mri.D(:, :, :, 1:15);   % 15番目までの画像を切り出し
figure; montage(D);      % D は、128x128x1x15 の配列（x1は、グレースケールの為）

%% 元データのボリュームデータの3次元表示 %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 側面の表示
D = squeeze(D);      % 次元を減らし、128x128x27の配列へ変換
vol = isosurface(D, 5);  % 一番外の側面：値5の等値面の、頂点と面を求める（背景は値0）
figure; patch(vol, 'FaceColor','red', 'EdgeColor','none');  % 等値面を表示
view(-40,24)                  % 視点の位置
daspect([1 1 0.3])            % X,Y,Z方向のアスペクト比の設定
colormap(gray); box on; camlight; lighting gouraud; % 照明等各種設定　　　　goraudで色が滑らかに変化するように

%% 上断面の表示
sec = isocaps(D, 5);   % 等値断面（等値面を作ったときの端の切断面）の頂点･面･輝度を求める
patch(sec, 'FaceColor','interp', 'EdgeColor','none'); shg; % 等値断面の表示

%% 3次元ガウシアンフィルタ・各スライス画像の表示 %%%%%%%%%%%%%%%%%%%%%%%%%
sigma = [2 2 2];                       % ガウシアンフィルタの各次元方向の標準偏差
volSmooth = imgaussfilt3(D, sigma);    % 3次元ガウシアンフィルタの適用
figure; montage(reshape(volSmooth, [128 128 1 15])); % 各スライス画像の表示
%% 結果の3次元表示
vol = isosurface(volSmooth, 5);  % 一番外の側面：値5の等値面の、頂点と面を求める（背景は値0）
figure; patch(vol, 'FaceColor','red', 'EdgeColor','none');  % 等値面を表示
view(-40,24)                  % 視点の位置
daspect([1 1 0.3])            % X,Y,Z方向のアスペクト比設定
colormap(gray); box on; camlight; lighting gouraud; % 照明等各種設定　　　　goraudで色が滑らかに変化するように
sec = isocaps(volSmooth, 5);     % 等値断面（等値面を作ったときの端の切断面）の頂点･面･輝度を求める
patch(sec, 'FaceColor','interp', 'EdgeColor','none'); shg; % 等値断面の表示

%% 3次の任意のフィルタ (imfilter) %%%%%%%%%%%%%%%%%%%
F = ones(3,3,3)/27          % 3x3x3 のフィルタ係数定義
volAve = imfilter(D, F);    % 3次元平均化フィルタの適用
figure; montage(reshape(volAve, [128 128 1 15])); % 各スライス画像の表示
%% 結果の3次元表示
vol = isosurface(volAve, 5);  % 一番外の側面：値5の等値面の、頂点と面を求める（背景は値0）
figure; patch(vol, 'FaceColor','red', 'EdgeColor','none');  % 等値面を表示
view(-40,24)                  % 視点の位置
daspect([1 1 0.3])            % X,Y,Z方向のアスペクト比設定
colormap(gray); box on; camlight; lighting gouraud; % 照明等各種設定　　　　goraudで色が滑らかに変化するように
sec = isocaps(volAve, 5);     % 等値断面（等値面を作ったときの端の切断面）の頂点･面･輝度を求める
patch(sec, 'FaceColor','interp', 'EdgeColor','none'); shg; % 等値断面の表示

%% 3次元の勾配強度の計算 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[Gmag, Gaz, Gelev] = imgradient3(D);
sz = size(D);
figure;
montage(reshape(Gmag,sz(1),sz(2),1,sz(3)),'DisplayRange',[]);




%% Copyright 2015 The MathWorks, Inc.
