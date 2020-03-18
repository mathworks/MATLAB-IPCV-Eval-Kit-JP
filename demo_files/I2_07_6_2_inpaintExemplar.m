%% 対話的な画像の修復
%% 画像の読み込み 
I = imread('greensdistorted.png');
%% 対話的な操作
% figureウィンドウの作成
h = figure('Name','Interactive Image Inpainting','Position',[0,0,700,400]);

% UIパネルの追加
dataPanel = uipanel(h,'Position',[0.01 0.5 0.25 0.5],'Title','Set parameter values','FontSize',10);

% パッチサイズ調整のためのUIの追加
uicontrol(dataPanel,'Style','text','String','Enter Patch Size','FontSize',10,'Position',[1 150 120 20]);
data.patchSize = uicontrol(dataPanel,'Style','edit','String',num2str(9),'Position',[7 130 60 20]);

% fill orderを選択するためのUIを追加
uicontrol(dataPanel,'Style','text','String','Select Filling Order','FontSize',10,'Position',[5 100 120 20]);
data.fillOrder = uicontrol(dataPanel,'Style','popupmenu','String',{'gradient','tensor'},'Position',[7 80 80 20]);

% 画像表示のためのパネルを追加
viewPanel = uipanel(h,'Position',[0.25 0 0.8 1],'Title','Interactive Inpainting','FontSize',10);
ax = axes(viewPanel);
%% 画像を表示
hImage = imshow(I,'Parent',ax); 
%% 画像にコールバック関数を追加
% ROIを指定すると画像修復が実行される
hImage.ButtonDownFcn = @(hImage,eventdata)clickCallback(hImage,eventdata,data);
%% 使用法
% ステップ１
% パッチサイズとfill orderを選択する
% 
% ステップ２
% 画像上で対話的にROIを指定する。クリック/ドラッグでROIの線を引き、ボタンを離すと領域指定を完了する
%% コールバック関数
function clickCallback(src,~,data)
% 変数の入力
fillOrder = data.fillOrder.String{data.fillOrder.Value};
pSize = data.patchSize.String;
patchSize = str2double(pSize);
% フリーハンドROIの入力受付
h = drawfreehand('Parent',src.Parent);
% マスクの作成
mask = h.createMask(src.CData);
% 画像修復の実行
newImage = inpaintExemplar(src.CData,mask,'PatchSize',patchSize,'FillOrder',fillOrder);
% 画像の更新
src.CData = newImage;
% ROIハンドルの消去
delete(h);
end
%% 
% _Copyright 2019 The MathWorks, Inc._