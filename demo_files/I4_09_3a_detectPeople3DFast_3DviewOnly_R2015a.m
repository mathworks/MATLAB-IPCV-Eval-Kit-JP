clc;close all;imtool close all;clear;

%% 左右の動画像を読込むオブジェクトの作成
readerLeft = vision.VideoFileReader('handshake_left.avi', ...
                              'VideoOutputDataType','uint8');
readerRight = vision.VideoFileReader('handshake_right.avi', ...
                              'VideoOutputDataType','uint8');
%% 動画を表示するためのオブジェクトを作成
player3D    = vision.DeployableVideoPlayer();

%% ステレオキャリブレーション結果の読込み
load('handshakeStereoParams.mat');

%% Stop ボタン表示
a=true;
sz = get(0,'ScreenSize');
figure('MenuBar','none','Toolbar','none','Position',[20 sz(4)-100 100 70])
uicontrol('Style', 'pushbutton', 'String', 'Stop',...
        'Position', [20 20 80 40],...
        'Callback', 'a=false;');
    
%% 元入力画像の確認
while ~isDone(readerLeft) && (a)
    % 左右のフレームの読込み
    frameLeft = step(readerLeft);
    frameRight = step(readerRight);
    
    step(player3D, [frameLeft, repmat(0, [480 10 3]), frameRight]);

    pause(0.05)
end
a = true;
release(readerLeft);
release(readerRight);
release(player3D);

%% メインループ
a = true;
readerLeft.PlayCount  = inf;
readerRight.PlayCount = inf;
while (a)
%for i=1:30
    % 左右のフレームの読込み
    frameLeft = step(readerLeft);
    frameRight = step(readerRight);
    
    % ステレオ平行化
    [frameLeftRect, frameRightRect] = rectifyStereoImages(frameLeft,...
        frameRight, stereoParams, 'OutputView', 'valid');
    % 3Dフレームの表示
    step(player3D, stereoAnaglyph(frameLeftRect, frameRightRect));

    pause(0.04)
end

release(readerLeft);
release(readerRight);
release(player3D);


%% Copyright 2014 The MathWorks, Inc.



