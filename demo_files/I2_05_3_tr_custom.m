clear all; close all; clc;

%% カスタム変換フォームによる幾何学的変換
%    p2c.m と c2p.m  を使用

%% 画像の入力と表示
load topo
I = topo(1:90,:);
figure
imagesc(I(end:-1:1,:),'CDataMapping','scaled');
colormap(topomap1)

%% カスタム変換フォームの作成
T = maketform('custom',2,2,@p2c,@c2p,[]);
udata = [-pi pi];   % 入力画像に対するX軸の範囲
vdata = [0 90];   % 入力画像に対するY軸の範囲
xdata = [-90 90];   % 出力画像に対するX軸の範囲
ydata = [-90 90];     % 出力画像に対するY軸の範囲


%% 幾何学的変換･表示
b = imtransform(I,T,'cubic','UData',udata,...
    'VData',vdata,'XData',xdata,'YData',ydata,...
    'Size',[180 180],'FillValues',0);

figure
imagesc(b,'CDataMapping','scaled');
colormap(topomap1)

%% 
% Copyright 2014 The MathWorks, Inc.
