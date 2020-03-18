%% コンピュータビジョンデモ：
% セクション実行
clear; close all; clc; imaqreset; clear videooptflowlines;

% ビデオカメラの初期設定(オブジェクト作成)   [一行]
%     (Image Acquisition Toolboxのシステムオブジェクト)
hVideo = imaq.VideoDevice('winvideo', 1, 'RGB24_640x480', 'ReturnedDataType','uint8');

%% オプティカルフロー検出のオブジェクトを作成
opticFlow = opticalFlowLK;
plotScaleFactor = 10;

% PCの画面にビデオを表示するビューワの作成
viewer = vision.DeployableVideoPlayer;
%viewer = vision.VideoPlayer;

% フレームレート計算用にタイマーをスタート
fps = single(0.0);cnt = 1;tic;

% Stop ボタン表示
a=true;
sz = get(0,'ScreenSize');
figure('MenuBar','none','Toolbar','none','Position',[20 sz(4)-100 100 70])
uicontrol('Style', 'pushbutton', 'String', 'Stop',...
        'Position', [20 20 80 40],...
        'Callback', 'a=false;');

%% 入力動画像を1フレームずつ処理するループ
while (a)
  frame = step(hVideo);         % カメラから1フレーム取込
  
  gFrame = rgb2gray(frame);                    % グレースケールへ変換
  flow  = estimateFlow(opticFlow, gFrame);     % オプティカルフロー計算
  lines = videooptflowlines(flow.Vx + i * flow.Vy, plotScaleFactor); % ベクトルの始点終点の計算 (5x5 ピクセルごと)
  
  % 結果の上書き
  frame1 = insertShape(frame, 'Line', lines, 'Color','red', 'SmoothEdges',false);
  frame2 = insertText(frame1, [50 50], ['Running at ' num2str(fps) 'fps'], 'FontSize',30, 'TextColor','green', 'BoxOpacity', 0);
  step(viewer,frame2);                 % 画面フレーム更新
  
   % 20フレームの所要時間からフレームレートを計算
   cnt = cnt + 1;
   if (mod(cnt,20) == 0)
    t = toc;
    fps = single(20/t);
    tic;
   end
   
   drawnow limitrate;      % ボタンの更新を、20 フレーム/秒に制限
end

clear videooptflowlines;      %to clear persistent variables.
release(hVideo);
release(viewer);

%% [終了]  Figure上のStopボタンで終了

%% 次に応用例の御紹介







%% [参考]
%動画で動かす例）hVideo = imaq.VideoDeviceの代わりに以下を使用
% hVideo = vision.VideoFileReader('visiontraffic.avi', 'PlayCount', inf);

%別のオプティカルフローアルゴリズムの例
% opticFlow = opticalFlowHS; plotScaleFactor = 200;
% opticFlow = opticalFlowFarneback; plotScaleFactor = 2;


%% Copyright 2013-2014 The MathWorks, Inc.


