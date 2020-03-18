%% 2つの画像の位置合せ(レジストレーション)
clear;clc;close all;imtool close all

%% 画像読み込み
aerial = imread('westconcordaerial.png');
figure, imshow(aerial)
ortho = imread('westconcordorthophoto.png');
figure, imshow(ortho)

%% 事前に選択した複数の点を読み込み
load westconcordpoints

%% コントロール ポイント選択ツールを開きます。
% 追加の点を選択するため、'Wait' パラメーターを使用して、cpselect を待機状態にします。
[aerial_points,ortho_points] = ...
       cpselect(aerial,'westconcordorthophoto.png',...
                movingPoints,fixedPoints,...
                'Wait',true);
%% レジストレーションを実行
% fitgeotrans を使用して、移動イメージを固定イメージに位置合わせする幾何学的変換を推定します。
% 選択したコントロール ポイントと必要な変換タイプを指定します。
t_concord = fitgeotrans(aerial_points,ortho_points,'projective');

%% imwarp を使用して変換を実行
ortho_ref = imref2d(size(ortho)); %relate intrinsic and world coordinates
aerial_registered = imwarp(aerial,t_concord,'OutputView',ortho_ref);
figure, imshowpair(aerial_registered,ortho,'blend')

%%  元の正射写真上に変換後のイメージを表示
% レジストレーションの効果を確認
figure, imshowpair(aerial_registered,ortho,'blend')

%% 終了

% Copyright 2014 The MathWorks, Inc.
