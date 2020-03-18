%% 動画中の動いている領域を検出
clc;clear;close all;imtool close all;

%% 動画を読込むためのオブジェクトの生成
videoSource = vision.VideoFileReader('atrium.mp4');

%% 動いている前景を検出するオブジェクトを生成
  detector = vision.ForegroundDetector('NumGaussians', 3, ...
       'NumTrainingFrames', 40, 'MinimumBackgroundRatio', 0.7);

%% 領域の座標取得用オブジェクトの生成 （400ピクセル以上のもの）
blob = vision.BlobAnalysis( 'AreaOutputPort',false, ...
          'CentroidOutputPort',false, 'BoundingBoxOutputPort',true, ...
          'MinimumBlobArea',400);

%% 動画表示用のオブジェクトの生成
sz = get(0,'ScreenSize');
videoPlayer = vision.VideoPlayer('Position', [150,sz(4)-490,1000,400]);

%% Stop ボタン表示
a=true;
sz = get(0,'ScreenSize');
figure('MenuBar','none','Toolbar','none','Position',[20 sz(4)-100 100 70])
uicontrol('Style', 'pushbutton', 'String', 'Stop',...
        'Position', [20 20 80 40], 'Callback', 'a=false;');

while ~isDone(videoSource) && a
  % 1フレーム取得
  frame  = step(videoSource);       % 1フレーム取得

  % 動いている領域の検出･枠を挿入
  fgMask = step(detector, frame);   % 動いている領域の検出
  bbox   = step(blob, fgMask);      % 領域の座標を取得
  out = insertShape(frame, 'Rectangle', bbox); % 四角枠を挿入
  
  % 結果の表示
  step(videoPlayer, [repmat(fgMask,[1,1,3]) out]); 
end
%%
release(videoPlayer);
release(videoSource);

%% Copyright 2016 The MathWorks, Inc.
