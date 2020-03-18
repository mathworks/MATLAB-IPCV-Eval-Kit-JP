clc;clear;close all;imtool close all;imaqreset;

%% 取込み用のシステムオブジェクトを生成
colorVid = videoinput('kinect',1);          %video input object for RGB (640 x 480)
depthVid = videoinput('kinect',2);          %video input object for depth

triggerconfig([colorVid depthVid], 'manual');
set([colorVid depthVid], 'FramesPerTrigger', 1);
set([colorVid depthVid], 'TriggerRepeat', Inf);
start([colorVid depthVid]);     % start device

%% デバイスの初期化
getsnapshot(colorVid);
getsnapshot(depthVid);

%% 一フレーム取得
colorImage = getsnapshot(colorVid);
depthImage = getsnapshot(depthVid);
ptCloud = pcfromkinect(depthVid,depthImage,colorImage);

%% 表示
player = pcplayer(ptCloud.XLimits,ptCloud.YLimits,ptCloud.ZLimits,...
	'VerticalAxis','y','VerticalAxisDir','down');
xlabel(player.Axes,'X (m)');ylabel(player.Axes,'Y (m)');zlabel(player.Axes,'Z (m)');

%% 停止ボタン表示
a=true;
sz = get(0,'ScreenSize');
figure('MenuBar','none','Toolbar','none','Position',[20 sz(4)-100 100 70])
uicontrol('Style', 'pushbutton', 'String', 'Stop',...
        'Position', [20 20 80 40],'Callback', 'a=false;');
      
% Start timer to calculate frame rate
tic;
cnt = 1;
fps = single(0.0);

%% ループ処理
while (a)
   colorImage = getsnapshot(colorVid);
   depthImage = getsnapshot(depthVid);
   ptCloud = pcfromkinect(depthVid,depthImage,colorImage);
 
   view(player,ptCloud);
   
   % Frame rate calculation from averaging 30 frame
   cnt = cnt + 1;
   if (mod(cnt,30) == 0)
     t = toc;
     fps = single(30/t)
     tic;
   end
end

release(colorVid);
release(depthVid);

%% 終了












%% ポスト表示 処理
% figure; pcshow(ptCloud, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down', 'MarkerSize',18)
% xlabel('X (m)');ylabel('Y (m)');zlabel('Z (m)'); box on;

%% Copyright 2015-2016 The MathWorks, Inc.
