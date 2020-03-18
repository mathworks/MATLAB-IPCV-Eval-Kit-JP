%% 初期化
clc;clear;close all;imtool close all; rng('default');

%% 動画の確認 (アプリケーション)
%implay('singleball.mp4');

%% パーティクルフィルタの作製
% We are measurement 6 states here (x, xd, xdd, y, yd, ydd)
pf = robotics.ParticleFilter;
pf.StateTransitionFcn = @I4_08_3_video_state_transition;
pf.MeasurementLikelihoodFcn = @I4_08_3_video_measurement;
pf.ResamplingMethod = 'stratified';
pf.StateEstimationMethod = 'mean';     % 全粒子位置の平均で、最終推定値を決定

%%  システムオブジェクト作成
videoReader = vision.VideoFileReader('singleball.mp4');
sz = get(0,'ScreenSize');
videoPlayer = vision.VideoPlayer('Position', [180,sz(4)-490,500,400]);
foregroundDetector = vision.ForegroundDetector('NumTrainingFrames', 10, 'InitialVariance', 0.05);
blobAnalyzer = vision.BlobAnalysis('AreaOutputPort', false, 'MinimumBlobArea', 70);

%% コマ送りボタン表示
a=true;
sz = get(0,'ScreenSize');
figure('MenuBar','none','Toolbar','none','Position',[20 sz(4)-100 100 70])
uicontrol('Style', 'pushbutton', 'String', '次のフレーム',...
        'Position', [20 20 80 40],'Callback', 'a=false;');

isFilterInitialized = false;
trackedPositions = [0 0 0];
position = [];

%% 動画を一フレームずつ処理
%      "次のフレーム" のボタンで、コマ送り
while ~isDone(videoReader)

    frame  = step(videoReader);  % 画像を1フレーム読込み

    % ボール (前景)の検出・中心点検出
    foregroundMask = step(foregroundDetector, rgb2gray(frame));
    detectedLocation = step(blobAnalyzer, foregroundMask);
    isObjectDetected = ~isempty(detectedLocation);
    
    if ~isFilterInitialized   % トラッキング始まっていない場合
      if isObjectDetected        % ボールを検出したとき
      % ボールが最初に検出された時、その位置で粒子(パーティクルフィルタ)を初期化
        numParticles = 8000;
        initialState = [detectedLocation(1) 20 0 detectedLocation(2) 0 0];
        initialCovariance = diag([16^2 4^2 4^2 16^2 4^2 4^2]);     % 共分散行列
        initialize(pf, numParticles, initialState, initialCovariance);
        
        isFilterInitialized = true;
        trackedLocation = correct(pf, detectedLocation(1,:));
        label = 'Initial';
      else   % ボールがまだ見つかっていない場合
        trackedLocation = [];label = '';
      end
    else    % トラッキング中の場合
      if isObjectDetected  % ボールが検出された場合
        % [予測]  粒子数分ノイズを生成
        %         各粒子の次時間の位置を状態遷移モデルで予測した後、各粒子にノイズを加える
        %         stateTransitionFcn が呼ばれる
        predict(pf);
        
        % [推定] 観測モデルにより、各予測位置での尤度を計算
        %        MeasurementLikelihoodFcn が呼ばれる:
        %        予測した各粒子位置と、実際の観測値の距離により尤度を決定
        %        尤度に従い、粒子を再配置（リサンプル）
        %         （尤度の低い位置の粒子は消滅。尤度の高い位置には複数の粒子を配置）
        %        全粒子の平均位置で最終予測位置を決定
        trackedLocation = correct(pf, detectedLocation(1,:));
        label = 'Corrected';
      else  % トラッキング中にボールが見つからなかった場合
        % 予測
        trackedLocation = predict(pf);
        label = 'Predicted';
      end
    end
    
  % 動画表示
  % 検出されたとき、検出された位置に青十字マーク
  if isObjectDetected
    combinedImage = insertMarker(frame, detectedLocation, 'Color','blue', 'Size',5);
  else
    combinedImage = frame;
  end
  
  % トラック(検出or予測)されているとき、場所に赤丸を重ね書き
  if ~isempty(trackedLocation)
    % 粒子位置に、マジェンタ色の点
    particleLoc = pf.Particles(:,[1,4]);
    particleLoc(:,3) = 0.7;           % 円の半径
    combinedImage = insertShape(combinedImage, 'FilledCircle', particleLoc, 'Color', 'magenta');
 
    position = trackedLocation([1,4]);
    position(:, 3) = 5;           % 円の半径
    combinedImage = insertObjectAnnotation(combinedImage, 'circle', position,label);
    %combinedImage = insertMarker(combinedImage, trackedLocation, 'Color','red');    position, {label}
  
    % 過去の点に緑丸
    combinedImage = insertShape(combinedImage, 'Circle', trackedPositions, 'Color', 'green');
    trackedPositions = [trackedPositions; position];
  end

  step(videoPlayer, combinedImage);   % ビデオ1フレーム表示

  while (a) 
    drawnow;   % プッシュボタンのイベントの確認
  end;
  a = true;

end % while

release(videoReader);

%% 終了















%% リサンプリングの方法
% multinomial (default)
% residual
% stratified
% systematic


%%
% Copyright 2016 The MathWorks, Inc.

