clear; close all; clc; imaqreset;

%% USB カメラからビデオを取込むオブジェクトの定義
vidobj = imaq.VideoDevice('winvideo', 1, 'RGB24_640x480');
%vidobj = vision.VideoFileReader('visionface.avi');

%% 物体認識オブジェクトの定義
%     顔認識用のトレーニングされたデータは内蔵
faceDetector = vision.CascadeObjectDetector('MinSize', [40 40]);

%% PCの画面にビデオを表示するビューワの定義
viewer = vision.DeployableVideoPlayer;

%% Stop ボタン表示
a=true;
sz = get(0,'ScreenSize');
figure('MenuBar','none','Toolbar','none','Position',[20 sz(4)-100 100 70])
uicontrol('Style', 'pushbutton', 'String', 'Stop',...
        'Position', [20 20 80 40],'Callback', 'a=false;');

%% カメラから1フレームずつ読込み処理をする
while (a) 
    frame = step(vidobj);              % カメラから1画面取込み
    bbox = step(faceDetector, frame);  % 顔の検出
    % 検出した顔の位置に、四角と連番を表示
    if ~isempty(bbox)
      frame = insertObjectAnnotation(frame,'rectangle',bbox,[1:size(bbox,1)], 'FontSize',24);
    end
    step(viewer, frame);          % 1画面表示
    
    drawnow limitrate;    % プッシュボタンのイベントの確認
end

release(vidobj);
release(faceDetector);
release(viewer);

%% 
% Copyright 2014 The MathWorks, Inc.
