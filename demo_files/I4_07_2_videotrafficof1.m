%% 初期化
clear; close all; clc;

%% 各種システムオブジェクトの生成
% 動画読込み用のオブジェクトの作成
filename = 'viptraffic.avi';
hVidReader = vision.VideoFileReader(filename, ...
                              'VideoOutputDataType','single', 'PlayCount',inf);
% オプティカルフロー用のオブジェクトの作成
opticFlow = opticalFlowHS;

% オプティカルフローの平均値を計算するオブジェクトの作成
hMean2 = vision.Mean('RunningMean', true);   % 現在までの全フレームの平均

% Blob解析：面積・境界ボックス・境界ボックス内のBlobの面積割合
hblob = vision.BlobAnalysis(...
    'CentroidOutputPort', false, 'AreaOutputPort', true, ...
    'BoundingBoxOutputPort', true, 'ExtentOutputPort', true, ...
    'OutputDataType', 'double', ...
    'MinimumBlobArea', 250, 'MaximumBlobArea', 3600, 'MaximumCount', 80);

% 表示用のオブジェクトの作成
f = figure;
sz = get(0,'ScreenSize');
pos = [180 sz(4)-500 200+700 300];
f.Position = pos;
ax1 = axes('Position', [0, 0, 0.25, 1]);
ax2 = axes('Position', [0.25, 0, 0.25, 1]);
ax3 = axes('Position', [0.5, 0, 0.25, 1]);
ax4 = axes('Position', [0.75, 0, 0.25, 1]);

% ストップボタンの表示
a=true;
figure('MenuBar','none','Toolbar','none','Position',[20 sz(4)-100 100 70])
uicontrol('Style', 'pushbutton', 'String', 'Stop',...
        'Position', [20 20 80 40],...
        'Callback', 'a=false;');
    
%%
% ループ処理のスタート
while (a)
    %% 動画を1フレーム読込み・表示  ====> 画面1:入力ビデオ
    frame  = step(hVidReader);                   % １フレーム読込み
    imshow(frame, 'Parent', ax1);                                 % 表示
    
    %% オプティカルフローの計算・表示  ====> 画面2
    grayFrame = rgb2gray(frame);                 % カラー画像をグレースケールへ変換
	flow  = estimateFlow(opticFlow, grayFrame);  % オプティカルフロー計算
    
    imshow(ones(120, 160, 3, 'single'), 'Parent', ax2)
    hold(ax2, 'on')
    plot(flow,'DecimationFactor',[3 3],'ScaleFactor',10,'Parent',ax2);
    hold(ax2, 'off')    
    
    %% 移動物体領域の抽出・表示  ====> 画面3
    y1 = flow.Magnitude;    % 各画素での速度の大きさ値を取得
		
    % 速度の面内平均 => 時間方向平均 => *4 を閾値とする
    vel_th = 4 * step(hMean2, mean(y1(:)));

    % 速度の2値画像を作成し、MedianFilterでノイズ除去
    segmentedObjects = medfilt2(y1 >= vel_th);

    % 収縮処理で白線等除去し、車部分の穴をClose処理で埋める   ===> 画面3: 二値画像ビデオ (速度の大きさで2値化し、クローズ処理)
    segmentedObjects2 = imclose(imerode(segmentedObjects, strel('square',2)), strel('line',5,45));
    imshow(segmentedObjects, 'Parent', ax3)
    
    %% 車の認識・台数の計数・表示  ====> 画面4
    % Blob解析：面積・境界ボックス・境界ボックス内のBlobの面積割合
    [area, bbox, extent] = step(hblob, segmentedObjects);

    isCar = extent > 0.4;   % 境界ボックス内の物体の割合が、40%以上のものを車と認識
    numCars = sum(isCar);   % 車の台数の計数
    bbox(~isCar, :) = [];   % 車と認識した境界ボックスのみ残す

    % 認識した車の周りに四角い境界ボックスを描画
    y2 = insertShape(frame, 'Rectangle', bbox, 'Color','green');
    
    % 車の台数を画像の左上に挿入
    y2(1:30,1:30,:) = 0;   % 数字が見やすいように、背景を黒くする
		result = insertText(y2, [5 1], numCars, 'FontSize',18, ...
			                  'BoxColor','black', 'BoxOpacity',0, 'TextColor','white');     % ====> 画面4
    imshow(result, 'Parent', ax4);           % 表示
        
    pause(0.1);                      % ウェイトを入れて、再生速度を見やすい速さへ下げる
    drawnow;                         % プッシュボタンのイベントの確認
end                              % while ループ文の最後

%%
release(hVidReader);
release(hMean2);
release(hblob);

%% 終了



% 動きを基にした車の検出
% 上から、22・23ピクセル目に横白線
%
% 速度の大きさで二値化
% 車線等を収縮処理で除去
% 車の中央等をクローズ処理
% Blob解析を基にで、境界ボックスを標示・台数表示
%
% Figure上の Stopボタン で終了
% 
% The output video shows the cars which were tracked by drawing boxes
% around them. The video also displays the number of tracked cars.


%% Copyright 2004-2018 The MathWorks, Inc.
% This is a script for Tracking Cars Using Optical Flow
%
% This can be found by the following command
%     web([docroot '/vision/examples/tracking-cars-using-optical-flow.html'])
% or the following URL.
%     http://www.mathworks.com/help/releases/R2012b/vision/examples/tracking-cars-using-optical-flow.html

% This example shows how to track cars in a video by detecting motion using optical 
% flow. The cars are segmented from the background by thresholding the 
% motion vector magnitudes. Then, blob analysis is used to identify 
% the cars.
