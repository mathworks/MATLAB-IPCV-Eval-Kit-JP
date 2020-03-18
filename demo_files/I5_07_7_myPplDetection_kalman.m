clc;clear;close all;imtool close all;

%% コンピュータビジョンデモ：人の検出・トラッキング
I = imread('I5_07_7_people2.png');
I1 = imresize(I, 1.5, 'Antialiasing',false);
figure; imshow(I);       % 1フレーム表示

%% 人の検出 （ここでは、製品内蔵の人の検出器を使用）
roi = [40 95 320 140];     % 検索領域を制限（空などでは検出不要）
bboxes = detectPeopleACF(I1, roi, 'Model','caltech', ...
            'WindowStride',2, 'NumScaleLevels', 4)

%% 検出された人の位置に、四角い枠とテキストを追加
I2 = insertObjectAnnotation(I1, 'rectangle', bboxes, 'People', 'FontSize',24, 'LineWidth', 2);
imshow(I2);shg;

%% 動画での検出
% 動画ファイルから画像を読込むオブジェクトの生成
videoReader = vision.VideoFileReader('vippedtracking.mp4', 'VideoOutputDataType','uint8');
% ビデオ表示用のオブジェクトの作成
sz = get(0,'ScreenSize');
%videoPlayer  = vision.DeployableVideoPlayer('Location',[10 sz(4)-300]);
videoPlayer  = vision.DeployableVideoPlayer();

% START/STOPボタン表示
a1=true; a2=true;
sz = get(0,'ScreenSize');
figure('MenuBar','none','Toolbar','none','Position',[20 sz(4)-150 100 120])
uicontrol('Style', 'pushbutton', 'String', 'START',...
        'Position', [20 70 80 40], 'Callback', 'a1=false;');
uicontrol('Style', 'pushbutton', 'String', 'STOP',...
        'Position', [20 20 80 40], 'Callback', 'a2=false;');
step(videoPlayer, I1);   
while a1; drawnow; end      % STARTボタンが押されるまで待つ
      
cnt = 1;
while ~isDone(videoReader) && a2 && cnt<230
  I = step(videoReader);   % 1フレーム読込み
  I = imresize(I, 1.5, 'Antialiasing',false);

  [bboxes, scores] = detectPeopleACF(I, roi, ...
          'Model','caltech', 'WindowStride', 2, 'NumScaleLevels', 4);

  % 検出された人の位置に、四角い枠とテキストを追加
  I2 = insertShape(I, 'rectangle', bboxes, 'LineWidth', 2);
  
  step(videoPlayer, I2);
  
  drawnow limitrate;
  cnt = cnt +1;
end

%% 再度実行（ウェイトを挿入してゆっくり実行）
release(videoReader);
a1=true; a2=true;
step(videoPlayer, I1);   
while a1; drawnow; end
      
cnt = 1;
while ~isDone(videoReader) && a2 && cnt<230
  I = step(videoReader);   % 1フレーム読込み
  I = imresize(I, 1.5, 'Antialiasing',false);

  [bboxes, scores] = detectPeopleACF(I, roi, ...
          'Model','caltech', 'WindowStride', 2, 'NumScaleLevels', 4);

  % 検出された人の位置に、四角い枠とテキストを追加
  I2 = insertShape(I, 'rectangle', bboxes, 'LineWidth', 2);
  
  step(videoPlayer, I2);
  
  drawnow limitrate;
  pause(0.2);
  cnt = cnt +1;
end


%% トラッキングを用いて補償（検出結果：黄色、補償結果：赤色）%%%%%%%%%%%%%%%%%%%
% 運動方程式を用い予測したり、誤差を含む観測値を補正
% カルマンフィルターと、ボールのセグメンテーションの、パラメータ設定（M次元の直交座標系に対応）
% カルマンフィルターのコンストラクタを用いることで細かくモデルの定義等可能
param.motionModel           = 'ConstantVelocity';  % 位置推定に用いる運動方程式：一定速度で移動するとして、次の位置を推定。等加速度モデルも可
param.initialEstimateError  = [2 1];               % それぞれトラッキング初期の位置･速度の推定値に対する分散 (正規分布)
param.motionNoise           = [5, 5];              % 運動方程式に対する誤差の分散 (位置、速度)
param.measurementNoise      = 100;                 % 検出された位置に対する誤差の分散 (正規分布)
  
% システムオブジェクト作成
release(videoReader);
isTrackInitialized    = false;

release(videoReader);
a1=true; a2=true;
step(videoPlayer, I1);   
while a1; drawnow; end
% 動画を一フレームずつ処理

cnt = 1;
while ~isDone(videoReader) && a2 && cnt<230

  I = step(videoReader);     % 1フレーム読み取り

  % 人(前景)の検出・中心点検出
  I = imresize(I, 1.5, 'Antialiasing',false);  
  [bboxes, scores] = detectPeopleACF(I, roi, ...
            'Model','caltech', 'WindowStride', 2, 'NumScaleLevels', 4);

  % 人が検出された場合、その位置に黄色で四角枠を描画
  if ~isempty(bboxes)     
    isObjectDetected = true;
    detectedLoc = [bboxes(1,1)+bboxes(1,3)/2  bboxes(1,2)+bboxes(1,4)/2];   %中心の計算
    % 検出された人の位置に、四角い枠(黄)と中心に丸(黄)を描画
    I = insertShape(I, 'rectangle', bboxes, 'LineWidth', 2);
    I = insertShape(I, 'FilledCircle', [detectedLoc 5], 'Color','Yellow', 'Opacity',1);
  else
    isObjectDetected = false;
    detectedLoc = [];
  end

  if ~isTrackInitialized   % トラッキング始まっていないとき
    if isObjectDetected      % 最初に人を検出したとき
      % 人が最初に検出された時、カルマンフィルターを作成
      kalmanFilter = configureKalmanFilter(param.motionModel, ...
        detectedLoc, param.initialEstimateError, ...             %検出された場所を初期位置に設定
        param.motionNoise, param.measurementNoise);

      isTrackInitialized = true;
      trackedLoc = correct(kalmanFilter, detectedLoc);
    else   % 人がまだ見つかっていない場合
      trackedLoc = [];label = '';
    end

  else    % トラッキング中の場合 (カルマンフィルタでトラッキング)
    if isObjectDetected    % 人が検出された場合
      predict(kalmanFilter);  % 画像ノイズ等による位置検出誤差を、予測値で低減(correction)
      trackedLoc = correct(kalmanFilter, detectedLoc);
    else  % トラッキング中に人が見つからなかった場合
      trackedLoc = predict(kalmanFilter); % 人の位置を予測
    end
  end

  % トラッキング位置に赤丸を上書き
  if ~isempty(trackedLoc)
    I = insertShape(I, 'FilledCircle', [trackedLoc 5], 'Color','Red', 'Opacity',1); 
  end

  step(videoPlayer, I);   % ビデオ1フレーム表示
  
  pause(0.2);
  cnt = cnt +1;
  drawnow limitrate;
end % while

release(videoReader);
release(videoPlayer);

%% 終了










% Copyright 2015 The MathWorks, Inc.

