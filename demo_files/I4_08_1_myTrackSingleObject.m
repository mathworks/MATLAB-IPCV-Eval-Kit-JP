clear all;clc;close all;imtool close all

%% 動画の表示 (スクリプト)
videoReader = vision.VideoFileReader('singleball.mp4');
sz = get(0,'ScreenSize');
videoPlayer = vision.VideoPlayer('Position', [10,sz(4)-500,500,400]);
while ~isDone(videoReader)
  frame = step(videoReader);  % 1フレーム読み取り
  step(videoPlayer, frame);   % ビデオ1フレーム表示
end

%% 動画の表示 (アプリケーション)
implay('singleball.mp4');

%% ボールをトラッキング ：カルマンフィルター %%%%%%%%%%%%%%%%%%%
% 運動方程式を用い予測したり、誤差を含む観測値を補正
% カルマンフィルターと、ボールのセグメンテーションの、パラメータ設定（M次元の直交座標系に対応）
% カルマンフィルターのコンストラクタを用いることで細かくモデルの定義等可能
param.motionModel           = 'ConstantVelocity';  % 位置推定に用いる運動方程式：一定速度で移動するとして、次の位置を推定。等加速度モデルも可
param.initialEstimateError  = 1E5 * ones(1, 2);    % それぞれトラッキング初期の位置･速度の推定値に対する分散 (正規分布)
param.motionNoise           = [25, 10];            % 運動方程式に対する誤差の分散 (位置、速度)
param.measurementNoise      = 25;                  % 検出された位置に対する誤差の分散 (正規分布)
param.segmentationThreshold = 0.05;
  
%% システムオブジェクト作成
videoReader = vision.VideoFileReader('singleball.mp4');
sz = get(0,'ScreenSize');
videoPlayer = vision.VideoPlayer('Position', [180,sz(4)-490,500,400]);
foregroundDetector = vision.ForegroundDetector('NumTrainingFrames', 10, 'InitialVariance', param.segmentationThreshold);
blobAnalyzer = vision.BlobAnalysis('AreaOutputPort', false, 'MinimumBlobArea', 70, 'CentroidOutputPort', true);   % 中心点の算出

isTrackInitialized    = false;
trackedPositions = [0 0 0];
position = [];

%% コマ送りボタン表示
a=true;
sz = get(0,'ScreenSize');
figure('MenuBar','none','Toolbar','none','Position',[20 sz(4)-100 100 70])
uicontrol('Style', 'pushbutton', 'String', '次のフレーム',...
        'Position', [20 20 80 40],'Callback', 'a=false;');

%% 動画を一フレームずつ処理
%      "次のフレーム" のボタンで、コマ送り
while (a) && ~isDone(videoReader)

  frame = step(videoReader);     % 1フレーム読み取り

  % ボール (前景)の検出・中心点検出
  foregroundMask   = step(foregroundDetector, frame);
  detectedLocation = step(blobAnalyzer, foregroundMask);
  isObjectDetected = ~isempty(detectedLocation);

    if ~isTrackInitialized   % トラッキング始まっていないとき
      if isObjectDetected      % 最初にボールを検出したとき
        % ボールが最初に検出された時、カルマンフィルターを作成
        kalmanFilter = configureKalmanFilter(param.motionModel, ...
          detectedLocation, param.initialEstimateError, ...             %検出された場所を初期位置に設定
          param.motionNoise, param.measurementNoise);

        isTrackInitialized = true;
        trackedLocation = correct(kalmanFilter, detectedLocation);
        label = 'Initial';
      else   % ボールがまだ見つかっていない場合
        trackedLocation = [];label = '';
      end

    else    % トラッキング中の場合 (カルマンフィルタでトラッキング)
      if isObjectDetected    % ボールが検出された場合
        predict(kalmanFilter);  % 画像ノイズ等による位置検出誤差を、予測値で低減(correction)
        trackedLocation = correct(kalmanFilter, detectedLocation);
        label = 'Corrected';
      else  % トラッキング中にボールが見つからなかった場合
        trackedLocation = predict(kalmanFilter); % ボール位置を予測
        label = 'Predicted';
      end
    end

  % 動画表示
  % 検出されたとき、検出された位置に青十字マーク
  if isObjectDetected
    combinedImage = insertMarker(frame, detectedLocation, 'Color','blue');
  else
    combinedImage = frame;
  end
  
  % トラック(検出or予測)されているとき、場所に赤丸を重ね書き
  if ~isempty(trackedLocation)
    position = trackedLocation;
    position(:, 3) = 5;           % 円の半径
    combinedImage = insertObjectAnnotation(combinedImage, 'circle', position, {label}, 'Color', 'red');
    %combinedImage = insertMarker(combinedImage, trackedLocation, 'Color','red');
  end
  
  % 過去の点に緑丸
  combinedImage = insertShape(combinedImage, 'Circle', trackedPositions, 'Color', 'green');
  trackedPositions = [trackedPositions; position];

  step(videoPlayer, combinedImage);   % ビデオ1フレーム表示
  
  while (a) 
    drawnow;   % プッシュボタンのイベントの確認
  end;
  a = true;
end % while
  
%%
release(videoReader);
release(videoPlayer);
release(foregroundDetector);
release(blobAnalyzer);

%% 終了










%% 軌跡を表示する場合
% [while ループの前に、]
%   accumulatedImage      = 0;
%   accumulatedDetections = zeros(0, 2);
%   accumulatedTrackings  = zeros(0, 2);
% [while ループの最後に]
%   accumulatedImage      = max(accumulatedImage, frame);
%   accumulatedDetections ...
%          = [accumulatedDetections; detectedLocation];
%   accumulatedTrackings  ...
%          = [accumulatedTrackings; trackedLocation];
% [while ループの最後に]
%   figure; imshow(accumulatedImage/2+0.5); hold on;
%   plot(accumulatedDetections(:,1), ...     %検出された位置に黒＋印
%        accumulatedDetections(:,2), 'k+');
%   plot(accumulatedTrackings(:,1), ...      %トラッキング結果を赤丸と直線で表示
%        accumulatedTrackings(:,2), 'r-o');
%   legend('Detection', 'Tracking');

%% vision.DeployableVideoPlayerを使う場合
% videoPlayer = vision.DeployableVideoPlayer('Location', [10,sz(4)-500]);

% Copyright 2014 The MathWorks, Inc.
