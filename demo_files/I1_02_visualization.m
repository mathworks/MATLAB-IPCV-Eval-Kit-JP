% スクリプトを開き、実行。GUIのNextボタンを押して次へ
clear;close all;clc

addpath('.\I1_02_grademo')

%% 2次元ラインプロット
line2d
ft=figure('units','normalized','position',[0.0381 0.6969 0.2871 0.2276], ...
       'menubar','none','numbertitle','off');
at=axes('visible','off');
text(0.5,0.5,{'2次元ラインプロット','(plot)'},'fontname','ＭＳ ゴシック', ...
        'fontsize',12,'FontWeight','bold','tag','titletext','parent',at, ...
        'VerticalAlignment','middle','HorizontalAlignment','center');
uicontrol('Style', 'pushbutton', 'String', 'Next',...
        'Position', [20 20 100 40],'parent',ft,...
        'Callback', 'a=false;');
a=true; while (a); drawnow; end;

%%  2次元ラインプロット(マーカーつき)
figure(1)
h=findobj(gca,'type','line');
set(h(1),'marker','o')
set(h(2),'marker','*')
set(h(3),'marker','d')
grid on
a=true; while (a); drawnow; end

%% 極座標プロット (polar)
clear
polarplot
ht=findobj('tag','titletext');
set(ht,'string','極座標プロット (polar)')
a=true; while (a); drawnow; end

%% コンパスプロット
clear
compassplot
ht=findobj('tag','titletext');
set(ht,'string',{'コンパスプロット','(compass)'})
a=true; while (a); drawnow; end

%% 領域の塗りつぶし (fill)
clear
fill2d
ht=findobj('tag','titletext');
set(ht,'string','領域の塗りつぶし (fill)')
a=true; while (a); drawnow; end

%% 2次元離散プロット (stem)
clear
stem2d
ht=findobj('tag','titletext');
set(ht,'string','2次元離散プロット (stem)')
a=true; while (a); drawnow; end

%% 階段状プロット (stairs)
clear
stair2d
ht=findobj('tag','titletext');
set(ht,'string','階段状プロット (stairs)')
a=true; while (a); drawnow; end

%% 3次元ラインプロット
clear
line3d
ht=findobj('tag','titletext');
set(ht,'string',{'3次元ラインプロット','(plot3)'})
a=true; while (a); drawnow; end

%% メッシュプロット (mesh)
clear
meshdemo
ht=findobj('tag','titletext');
set(ht,'string','メッシュプロット (mesh)')
a=true; while (a); drawnow; end

%% 表面プロット (surf)
clear
surfdemo
ht=findobj('tag','titletext');
set(ht,'string','表面プロット (surf)')
a=true; while (a); drawnow; end

%% 3次元断面プロット (slice)
clear
slicedemo
ht=findobj('tag','titletext');
set(ht,'string','3次元断面プロット (slice)')
a=true; while (a) drawnow; end

%% 3次元オブジェクト (surf)
clear
obj3d1
ht=findobj('tag','titletext');
set(ht,'string','3次元オブジェクト (surf)')
a=true; while (a) drawnow; end

%% 2次元等高線図 (contour)
clear
cont2d
ht=findobj('tag','titletext');
set(ht,'string','2次元等高線図 (contour)')
a=true; while (a) drawnow; end

%% 塗りつぶし2次元等高線図
clear
cont2df
ht=findobj('tag','titletext');
set(ht,'string',{'塗りつぶし2次元等高線図','(contour)'})
a=true; while (a); drawnow; end

%% 3次元等高線図 (contour3)
clear
cont3d
ht=findobj('tag','titletext');
set(ht,'string','3次元等高線図 (contour3)')
a=true; while (a) drawnow; end

%% 円グラフ (pie)
clear
piedemo
ht=findobj('tag','titletext');
set(ht,'string','円グラフ (pie)')
a=true; while (a); drawnow; end
 
%% 棒グラフ
% clear
% bargraph
% ht=findobj('tag','titletext');
% set(ht,'string','棒グラフ')
%a=true; while (a) drawnow; end

%% ヒストグラム (hist)
clear
histplot
ht=findobj('tag','titletext');
set(ht,'string','ヒストグラム (hist)')
a=true; while (a); drawnow; end

%% 画像表示 (imshow)
clear
implot
ht=findobj('tag','titletext');
set(ht,'string','画像表示 (imshow)')
a=true; while (a); drawnow; end

%% warp
clear
warpdemo
ht=findobj('tag','titletext');
set(ht,'string',{'サーフェースへの','画像の貼り付け (warp)'})
a=true; while (a); drawnow; end

%% アニメーション
%clear
%anim
%ht=findobj('tag','titletext');
%set(ht,'string','アニメーション')
% a=true; while (a) drawnow; end

%% Delaunayの三角メッシュ
% clear
% close all
% tridemo
% ft=figure('units','normalized','position',[0.6367 0.7279 0.2871 0.1276], ...
%        'menubar','none','numbertitle','off');
% at=axes('visible','off');
% ht=text(0.5,0.5,'Delaunayの三角メッシュ','fontname','ＭＳ ゴシック', ...
%         'fontsize',17,'FontWeight','bold','tag','titletext1','parent',at, ...
%         'VerticalAlignment','middle','HorizontalAlignment','center');
% a=true; while (a) drawnow; end

%% メッシュ、コンター
% clear
% meshcontour
% ht=findobj('tag','titletext1');
% set(ht,'string',{'メッシュ、コンター、','ベクトルによる表示'})
% a=true; while (a) drawnow; end


% clear
% close all
% mixplot
% ft=figure('units','normalized','position',[0.0381 0.7969 0.2871 0.1276], ...
%        'menubar','none','numbertitle','off');
% at=axes('visible','off');
% ht=text(0.5,0.5,{'風の動きの円錐プロット','ストリームライン','等値面'},'fontname','ＭＳ ゴシック', ...
%         'fontsize',14,'FontWeight','bold','tag','titletext','parent',at, ...
%         'VerticalAlignment','middle','HorizontalAlignment','center');
%a=true; while (a) drawnow; end

%% 流速の等値面
clear
flowiso2
ht=findobj('tag','titletext');
set(ht,'string',{'流速の等値面', '(patch, isosurface)'})
a=true; while (a); drawnow; end

%% スライス平面上に等高線
clear
cslice
ht=findobj('tag','titletext');
set(ht,'string',{'スライス平面上に等高線','(contourslice)'})
a=true; while (a); drawnow; end

%% 頭部の断面図
clear
headiso_h
ht=findobj('tag','titletext');
set(ht,'string',{'頭部の断面図','(patch, isosurface)','(patch, isocaps)'})
a=true; while (a); drawnow; end

%% movie
clear
ht=findobj('tag','titletext');
set(ht,'string',{'アニメーション','(movie)'})
animdemo

%% 終了
clear
ht=findobj('tag','titletext');
set(ht,'string','終了')

rmpath('.\I1_02_grademo')

%% Copyright 2014 The MathWorks, Inc.
