clc;close all;imtool close all;clear;imaqreset;

%% カメラから画像を取り込むためのオブジェクトの生成
%vidobj = videoinput('winvideo', 1, 'RGB24_640x480')      % 環境に合わせて、Webcamの番号を設定
vidobj = videoinput('winvideo', 1, 'RGB24_1920x1080') 
triggerconfig(vidobj, 'manual')       % マニュアルトリガで、getsnapshotのオーバーヘッドを削減
start(vidobj);

%% ビデオを表示するためのオブジェクトの生成
viewer = vision.DeployableVideoPlayer;

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
  I = getsnapshot(vidobj);   %1フレーム取込み (uint8)
  step(viewer,I);            %1フレーム表示

  drawnow limitrate;
end

%%
stop(vidobj);
delete(vidobj);
release(viewer);

%%
%  Copyright 2014 The MathWorks, Inc.


