%% 顔検出ならびにKLTアルゴリズムを用いたトラッキング
%   顔が傾いたり距離が変わっても連続したトラッキング
clc;close all;imtool close all;clear;

%% Step1：顔の検出
% 動画ファイルから画像を読込むオブジェクトの生成
videoFileReader = vision.VideoFileReader('tilted_face.avi');

% 顔検出用オブジェクトの生成
faceDetector = vision.CascadeObjectDetector();

% 1フレーム読込み、顔を検出
frame = step(videoFileReader); 
bbox       = step(faceDetector, frame);

% 検出した顔の領域を表示
frame = insertShape(frame, 'Rectangle', bbox, 'LineWidth',5);
figure; imshow(frame); title('Detected face');

% 検出した顔の回転の可視化のために四隅の点座標へ変換
bboxPoints = bbox2points(bbox(1, :));

%% Step2：検出した顔領域で、特徴点(トラッキングする対象)を検出
%   (毎フレーム顔検出すると速度が低下・まっすぐな顔のみの検出器を使用)

% 顔の領域で、コーナー点を検出
points = detectMinEigenFeatures(rgb2gray(frame), 'ROI', bbox);

% Display the detected points.
figure, imshow(frame), hold on, title('Detected features');
plot(points);

%% Step3：ポイントトラッカーを初期化
% ポイントトラッキングのオブジェクトの作成 (エラーの大きな点は削除していくように設定)
pointTracker = vision.PointTracker('MaxBidirectionalError', 2);
% 最初のフレームと、それのフレームで検出したコーナー点でトラッカーを初期化
points = points.Location;
initialize(pointTracker, points, frame);  

%% 顔のトラッキング
% ビデオ表示用のオブジェクトの作成
videoPlayer  = vision.VideoPlayer('Position',...
    [100 100 [size(frame, 2), size(frame, 1)]+30]);

%% Stop ボタン表示
a=true;
sz = get(0,'ScreenSize');
figure('MenuBar','none','Toolbar','none','Position',[20 sz(4)-100 100 70])
uicontrol('Style', 'pushbutton', 'String', 'Stop',...
        'Position', [20 20 80 40], 'Callback', 'a=false;');

oldPoints = points;
while ~isDone(videoFileReader) && a
  frame = step(videoFileReader);   % 1フレーム読込み

  % 点のトラッキング
  [points, isFound] = step(pointTracker, frame);
  visiblePoints = points(isFound, :);  % 現フレームで見つかった点
  oldInliers = oldPoints(isFound, :);  % 前フレームの点の中で、現フレームでも見つかったもの
    
  if size(visiblePoints, 1) >= 2   %ポイントが2つ以上見つかったとき
      % 結果の表示のため、前フレームから現フレームへの変換行列を求める
      [xform, oldInliers, visiblePoints] = estimateGeometricTransform(...
          oldInliers, visiblePoints, 'similarity', 'MaxDistance', 4);
      % 境界ボックスを幾何学変換
      bboxPoints = transformPointsForward(xform, bboxPoints);
      % 画像フレームに、境界ボックスと点を挿入
      bboxPolygon = reshape(bboxPoints', 1, []);     % 一行へ変換
      frame = insertShape(frame, 'Polygon', bboxPolygon, 'LineWidth',5);
      frame = insertMarker(frame, visiblePoints, '+', 'Color', 'white');       
      % 現フレームで見つかったポイントで、トラッカーを再初期化
      oldPoints = visiblePoints;
      setPoints(pointTracker, oldPoints);        
  end
    
  step(videoPlayer, frame);   % 1フレーム表示
end

% Clean up
release(videoFileReader);
release(videoPlayer);
release(pointTracker);

%%   Copyright 2012 The MathWorks, Inc.
