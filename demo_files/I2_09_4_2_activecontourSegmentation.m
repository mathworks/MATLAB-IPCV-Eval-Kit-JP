%% 動的輪郭を用いたセグメンテーション
clc;close all;imtool close all;clear;

%% 画像の読込み
G = imread('I2_09_4_2_nuclei.jpg');
imshow(G);

%% マスクの作成（初期エッジ）
mask = zeros(size(G));
mask(25:end-25,25:end-25) = 1;
imshow(mask);shg;

%% 現在のマスクの輪郭を描画
imshow(G); shg; hold on;
b = bwboundaries(mask, 'noholes'); % 輪郭を抽出
plot(b{1}(:,2),b{1}(:,1),'r','LineWidth',3);
hold off;

%% 動的輪郭を使用したセグメンテーション
%    総計400回の反復を、1ステップ10回ずつに分けてアニメーション表示
stepsize=10;
for k = 1:400/stepsize
  mask = activecontour(G, mask, stepsize);

  % 現在のマスクの輪郭を描画
  imshow(G); title(sprintf('Iteration %d',k*stepsize),'FontSize',16);
  b = bwboundaries(mask, 'noholes'); % 輪郭を抽出
  hold on;
  for k=1:size(b)
    plot(b{k}(:,2),b{k}(:,1),'r','LineWidth',3);
  end
  hold off;
  drawnow;
end


%% イメージの領域分割 アプリケーション: 
imageSegmenter(G);


%% Copyright 2013-2014 The MathWorks, Inc.

