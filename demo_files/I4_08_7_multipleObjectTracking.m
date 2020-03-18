%% Multiple Object Tracking チュートリアル
clear; close all; clc;
videoObjects = setupVideoObjects('singleball.mp4');

%% 動画再生 - どのような動画ファイルを扱うのかを確認します
implay('singleball.mp4')

%% Next&Stop ボタン表示
a=true;
b=true;
sz = get(0,'ScreenSize');
figure('MenuBar','none','Toolbar','none','Position',[20 sz(4)-200 100 130])
uicontrol('Style', 'pushbutton', 'String', 'Next',...
    'Position', [20 20 80 40],'Callback', 'a=false;');
uicontrol('Style', 'pushbutton', 'String', 'Stop',...
    'Position', [20 80 80 40],'Callback', 'b=false;');
      
%% メインループ
frameCount = 0;
while b
    % ビデオフレームの読み込み
    frameCount = frameCount + 1;                                % フレーム数カウント
    frame = readFrame(videoObjects.reader);                     % 1フレーム読み込み
    %物体検出&トラッキング
    [confirmedTracks, mask, numDetections] = myTracker(frame, frameCount);
    %結果の可視化
    displayTrackingResults(videoObjects, confirmedTracks, frame, mask, numDetections);
    % "Next"ボタンが押されるまで停止
    while (a&&b)
        drawnow limitrate;
    end
    if ~videoObjects.reader.hasFrame
        break;
    end
    a = true;
end

%% ビデオオブジェクトの生成
function videoObjects = setupVideoObjects(filename)
        
    % 動画ファイル読み込み用オブジェクトの定義
    videoObjects.reader = VideoReader(filename);
    frame = 0;
    videoObjects.reader.CurrentTime = (1/videoObjects.reader.FrameRate) * frame;
        
    % 結果可視化用のPlayerオブジェクトの定義  
    videoObjects.maskPlayer  = vision.VideoPlayer('Position', [20, 400, 700, 400]);
    videoObjects.videoPlayer = vision.VideoPlayer('Position', [740, 400, 700, 400]);
end

%% トラッキング結果の可視化
function displayTrackingResults(videoObjects, confirmedTracks, frame, mask, numDetections)
    % データ型変換
    frame = im2uint8(frame);
    mask = uint8(repmat(mask, [1, 1, 3])) .* 255;
        
    if ~isempty(confirmedTracks)        
        % 検出されたオブジェクトの可視化
        % オブジェクトが検出されなかった場合は、予測値による結果が可視化されます
        numRelTr = numel(confirmedTracks);
        boxes = zeros(numRelTr, 4);
        ids = zeros(numRelTr, 1, 'int32');
        color_tbl = cell(numRelTr, 1);
        predictedTrackInds = zeros(numRelTr, 1); 
        for tr = 1:numRelTr
            color_tbl{tr} = 'yellow';
            % オブジェクトのBounding Box取得
            boxes(tr, :) = confirmedTracks(tr).ObjectAttributes{1}{1};
             
            % トラックのID取得
            ids(tr) = confirmedTracks(tr).TrackID;
            
            % オブジェクトが検出されなかった場合
            if confirmedTracks(tr).IsCoasted
                predictedTrackInds(tr) = tr;
                boxes(tr, 1:2) = [confirmedTracks(tr).State(1), confirmedTracks(tr).State(3)];
                boxes(tr, 3:4) = 15;
                color_tbl{tr} = 'red';
            end
        end
            
        predictedTrackInds = predictedTrackInds(predictedTrackInds > 0);
            
        % トラックIDをラベルとして抽出
        labels = cellstr(int2str(ids));
            
        isPredicted = cell(size(labels));
        isPredicted(predictedTrackInds) = {' predicted'};
        labels = strcat(labels, isPredicted);
            
        % 注釈を挿入(元画像)
        frame = insertObjectAnnotation(frame, 'rectangle', boxes, labels, 'Color',color_tbl);
            
        % 注釈を挿入(前景検出結果の2値画像)
        mask = insertObjectAnnotation(mask, 'rectangle', boxes, labels);
    end
        
    % Player更新
    videoObjects.maskPlayer.step(mask);        
    videoObjects.videoPlayer.step(frame);
end

function [confirmedTracks mask numDetections] = myTracker(frame, frameCount)

    persistent tracker
    persistent detector
    
    % multiObjectTrackerの定義
    if isempty(tracker)
        tracker = multiObjectTracker(...
        'FilterInitializationFcn', @initDemoFilter, ...
        'AssignmentThreshold', 30, ...       % 検出結果をトラックとして割り当てる閾値
        'NumCoastingUpdates', 10, ...　      % Coasting状態でトラックを維持する長さ
        'ConfirmationParameters', [6 10] ... % トラックとして認識されるまでの長さ
        );
    end
    
    % 前景検出用オブジェクトの定義
    if isempty(detector)
        detector = vision.ForegroundDetector('NumGaussians', 3, ...
            'NumTrainingFrames', 40, 'MinimumBackgroundRatio', 0.7);
    end

    measurementNoise = 100*eye(2);  
    % 前景検出
    mask = detector.step(frame);
    % ノイズ除去
    mask = imopen(mask, strel('rectangle', [6, 6]));
    mask = imclose(mask, strel('rectangle', [50, 50])); 
    mask = imfill(mask, 'holes');
    % プロパティ解析
    stats = regionprops(mask, 'Centroid', 'BoundingBox');

    % objectDetectionsオブジェクトにPack
    numDetections = size(stats, 1);
    detections = cell(numDetections, 1);
    if ~isempty(stats)
        for i = 1:numDetections
            detections{i} = objectDetection(frameCount, stats(i).Centroid, ...
                'MeasurementNoise', measurementNoise, ...
                'ObjectAttributes', {stats(i).BoundingBox});
        end
    end

    % トラック更新
    confirmedTracks = updateTracks(tracker, detections, frameCount);
end

function filter = initDemoFilter(detection)
    % カルマンフィルタの初期化
    
    % 初期状態の定義
    state = [detection.Measurement(1); 0; detection.Measurement(2); 0];

    % 初期誤差共分散行列の定義
    stateCov = diag([50, 50, 50, 50]);

    % カルマンフィルタの定義(2D 等速モデル)
    filter = trackingKF('MotionModel', '2D Constant Velocity', ...    
        'State', state, ...
        'StateCovariance', stateCov, ... 
        'MeasurementNoise', detection.MeasurementNoise(1:2,1:2) ...    
        );
end

% Copyright 2018 The MathWorks, Inc.