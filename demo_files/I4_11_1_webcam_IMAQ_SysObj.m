clc;close all;imtool close all;clear;

%% カメラから画像を取り込むためのシステムオブジェクトの生成
hCamera = imaq.VideoDevice('winvideo', 1, 'RGB24_640x480')      % 環境に合わせて、Webcamの番号(2番目の引数)を設定
hCamera.ReturnedDataType = 'uint8';       %デフォルトはSingle型：表示等uint8へ変換し、高速化

%% ビデオを表示するためのオブジェクトの生成
viewer = vision.DeployableVideoPlayer;

%% フレームレートを書き込むためのオブジェクトを生成
fps = single(0.0);
texts = vision.TextInserter('Running at %2.2f fps', ...
  'Color',[0, 255, 0], 'FontSize',30, 'Location',[20 20]); 

%% フレームレート計測用
t = tic();
cnt = 1;

%% ストップボタンの表示
a=true;
sz = get(0,'ScreenSize');
figure('MenuBar','none','Toolbar','none','Position',[20 sz(4)-100 100 70])
uicontrol('Style', 'pushbutton', 'String', 'Stop',...
        'Position', [20 20 80 40],...
        'Callback', 'a=false;');

%% 1フレーム毎に処理するためのループ処理
while (a)
% for i=1:200 
  I = step(hCamera);         %1フレーム取込み
  Itxt = step(texts,I,fps);  %フレームレートの書込み
  step(viewer,Itxt);         %1フレーム表示

   % 30フレームの平均からフレームレートの計算
   cnt = cnt + 1;
   if (mod(cnt,30) == 0)
    t = toc(t);
    fps = single(30/t);
    t = tic();
   end
   drawnow limitrate;
end

%%
release(hCamera);
release(viewer);
release(texts);

%%



%% 参考：各種設定をする例
hCamera.DeviceProperties.FrameRate = '5';     %フレームレートを5fps(毎秒5フレーム)へ変更





%%
%  Copyright 2014 The MathWorks, Inc.


