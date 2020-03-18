%% Motion-Based Multiple Object Tracking
%    トラッキング技術：動作認識、交通監視、自動車の危険検知等への応用
%　　Step#1：各フレーム内での動いている物体の検出
%    Step#2：フレーム間での関連付け
% Kalmanフィルターを使用
% 実行ボタンでデモ

clc;close all;imtool close all;clear;

% Stop ボタン表示
a=true;
sz = get(0,'ScreenSize');
figure('MenuBar','none','Toolbar','none','Position',[20 sz(4)-100 100 70])
uicontrol('Style', 'pushbutton', 'String', 'Stop',...
        'Position', [20 20 80 40], 'Callback', 'a=false;');
    
%% 各種System Objectsの生成 %%%%%
% 動画読込みのオブジェクト生成
  obj.reader = vision.VideoFileReader('atrium.mp4');
% 動画表示用オブジェクトの生成
  obj.videoPlayer = vision.VideoPlayer('Position', [ 20, sz(4)-600, 700, 400]);
  obj.maskPlayer  = vision.VideoPlayer('Position', [740, sz(4)-600, 700, 400]);     
% 動いている前景を検出するオブジェクトを生成
  obj.detector = vision.ForegroundDetector('NumGaussians', 3, ...
       'NumTrainingFrames', 40, 'MinimumBackgroundRatio', 0.7);
% ブロブ解析用のオブジェクトの作成（中心点・境界ボックス）
  obj.blobAnalyser = vision.BlobAnalysis( 'AreaOutputPort',false, ...
          'CentroidOutputPort', true,  'BoundingBoxOutputPort', true, ...
          'MinimumBlobArea', 400, 'ExcludeBorderBlobs',true);

% トラック（各トラックに、各動いている物体の情報を格納）の初期化
tracks = struct(...
  'id',           {}, ...       % ID番号
  'bbox',         {}, ...       %現フレーム内の境界ボックス（表示用）
  'kalmanFilter', {}, ...       %この物体トラッキング用のカルマンフィルター
  'trails',       [], ...       % 軌跡表示用に、過去の位置を保存
  'age',               {}, ...  %最初に検出されてからのフレーム数
  'totalVisibleCount', {}, ...      %検出された全フレーム数           => これが閾値を超えたら表示する
  'consecutiveInvisibleCount', {}); %連続した非検出フレーム数         => これが閾値を超えたらこのトラックを削除

nextId = 1; % ID of the next track

%% メインループ %%%%%
while (a && ~isDone(obj.reader))
  frame = step(obj.reader);     % 1フレーム読み込み
  
  %% [フレーム内で動いている全物体の検出] %%%%%
  % フレーム内の物体を検出：動いている物体(領域)の検出：maskは1が前景・0が背景
  mask = step(obj.detector, frame);  % 2値マスク画像：ForegroundDetectorを使用
  % 前処理：細かなノイズの除去・穴を埋める
  mask = imopen(mask, strel('rectangle', [3,3]));      %収縮->膨張：ごみ・ブリッジ除去
  mask = imclose(mask, strel('rectangle', [15, 15]));  %膨張->収縮：穴・スリット埋め
  mask = imfill(mask, 'holes');
  % 中心点・境界ボックスの検出
  [centroids, bboxes] = step(obj.blobAnalyser, mask);

  %% [現フレーム内での位置を前フレームから予測] %%%%%
  % カルマンフィルタを用いて、前フレームまでに検出済みの各物体(トラック)の位置予測
  for i = 1:length(tracks)
    bbox = tracks(i).bbox;    % 前フレームでの境界ボックス
    % 現フレームでの位置の予測
    predictedPosition = int32(predict(tracks(i).kalmanFilter));
    % 境界ボックスの中心を、予測重心位置へ調整
    tracks(i).bbox = [predictedPosition - bbox(3:4)/2, bbox(3:4)];
  end
  
  %% 既検出物体(トラック)に、検出された物体を対応付け %%%%%
  % コストの計算：既検出物体の予測位置と各検出物体の距離
  cost = zeros(length(tracks), size(centroids, 1));         % トラック数 x 検出数
  for i = 1:length(tracks)
      cost(i, :) = distance(tracks(i).kalmanFilter, centroids);
  end
  
  % 各トラックに検出された物体を割当 (ハンガリアンアルゴリズム：コストの合計が最小になるように）
  % assignment:トラック番号と検出番号の組が代入される
  costOfNonAssignment = 20;     %小さいと既存トラックにアサインされないもの増える=>新しいトラックが多く生成される
  [assignments, unassignedTracks, unassignedDetections] = ...
              assignDetectionsToTracks(cost, costOfNonAssignment);

  %% 対応する物体が見つかったトラックの情報更新 %%%%%
  for i = 1:size(assignments, 1)
      trackIdx = assignments(i, 1);           %トラックの番号
      detectionIdx = assignments(i, 2);       %検出物体の番号
      centroid = centroids(detectionIdx, :);  %その検出された物体iの中心点を抽出（obj.blobAnalyser.step(mask)の結果を使用）
      bbox = bboxes(detectionIdx, :);         %その検出された物体の境界ボックスを抽出（obj.blobAnalyser.step(mask)の結果を使用)

      % 検出された位置と予測値を用いて、現在位置を推定
      c2 = correct(tracks(trackIdx).kalmanFilter, centroid);

      % 各トラック情報を更新：境界ボックス、age、totalVisibleCount、consecutiveInvisibleCount
      tracks(trackIdx).bbox = bbox;
      tracks(trackIdx).trails{end+1} = c2;
      tracks(trackIdx).age = tracks(trackIdx).age + 1;
      tracks(trackIdx).totalVisibleCount = ...
          tracks(trackIdx).totalVisibleCount + 1;
      tracks(trackIdx).consecutiveInvisibleCount = 0;
  end
    
  %% 対応する物体が見つからなかったトラックの情報更新 %%%%%
  %           age、consecutiveInvisibleCount
  for i = 1:length(unassignedTracks)
    ind = unassignedTracks(i);
    %tracks(ind).trails{end+1} = predict(tracks(ind).kalmanFilter);    % 予測位置軌跡の表示
    tracks(ind).age = tracks(ind).age + 1;
    tracks(ind).consecutiveInvisibleCount = ...
                  tracks(ind).consecutiveInvisibleCount + 1;
  end
  

  %% 見失ったトラックを消去 %%%%%
  % 連続20フレーム以上不観測でトラックから消去
  if ~isempty(tracks)
    % compute the fraction of the track's age for which it was visible
    ages = [tracks(:).age];
    totalVisibleCounts = [tracks(:).totalVisibleCount];
    visibility = totalVisibleCounts ./ ages;     % 全age中で観測されたフレームの割合
      
    % find the indices of 'lost' tracks
    lostInds = (ages < 8 & visibility < 0.6) | ...
               ([tracks(:).consecutiveInvisibleCount] >= 20);   %20フレーム以上連続不観測で消去

    tracks = tracks(~lostInds);   %見失ったトラックの消去
  end

  %% 新たに見つかった物体に対し、新しいトラックを生成 %%%%%
  %      (ここではアサインされなかったトラックを、新しいトラックとする)
        centroids1 = centroids(unassignedDetections, :);           % Nx2 double
        bboxes = bboxes(unassignedDetections, :);                 % Nx4 int32
        
        for i = 1:size(centroids1, 1)
            
            centroid = centroids1(i,:);
            bbox = bboxes(i, :);
            
            % あたらしい物体一つに対して、カルマンフィルターを1つ生成
            % http://www.mathworks.com/videos/introduction-to-kalman-filters-for-object-tracking-79674.html
            kalmanFilter = configureKalmanFilter('ConstantVelocity', ...
                centroid, ...     % 初期座標
                [200, 50], ...    % InitialEstimateError ? Initial estimate uncertainty variance [位置用 速度用]   速度・加速度は初期値0
                [100, 25], ...    % MotionNoise ? Deviation of selected and actual model
                100);             % MeasurementNoise ? Variance inaccuracy of detected location  増やすとMotionModel優先

            
            % 新しいトラックの生成
            newTrack = struct(...
                'id', nextId, ...
                'bbox', bbox, ...
                'kalmanFilter', kalmanFilter, ...
                'trails',{{}},...
                'age', 1, ...
                'totalVisibleCount', 1, ...
                'consecutiveInvisibleCount', 0);
            newTrack.trails{1} = centroid;
            
            % 生成した新しいトラックを、トラックの配列の最後に追加
            tracks(end + 1) = newTrack;
            
            % nextIdを1つ増やす
            nextId = nextId + 1;
        end

    
%% [結果の表示] %%%%%
        frame = im2uint8(frame);
        mask = uint8(repmat(mask, [1, 1, 3])) .* 255;  %uint8 RGBへ変換

        if ~isempty(tracks)

            reliableTrackInds = ...
                [tracks(:).totalVisibleCount] > 8;         % 検出回数<8回のものは、まだ表示しない
            reliableTracks = tracks(reliableTrackInds);
            
            if ~isempty(reliableTracks)
                % 境界の四角枠の座標の抽出
                bboxes = cat(1, reliableTracks.bbox);
                
                % ID番号の取得
                ids = int32([reliableTracks(:).id]);
                
                labels = cellstr(int2str(ids'));
                predictedTrackInds = ...
                    [reliableTracks(:).consecutiveInvisibleCount] > 0;
                isPredicted = cell(size(labels));
                isPredicted(predictedTrackInds) = {' predicted'};    % 推定した場所の場合
                labels = strcat(labels, isPredicted);
                
                % RGBのフレームの中に、四角枠を描画
                frame = insertObjectAnnotation(frame, 'rectangle', ...
                    bboxes, labels);
                
                % RGBのフレーム内に、軌跡を表示
                for i = 1:length(tracks)
                  p = cat(1,tracks(i).trails{:});                % トラック毎に、軌跡の座標 Nx2 を取得
%                  frame = insertMarker(frame, p, 'o', 'color', 'red', 'size', 3);    % 軌跡をoで表示
                  if size(p,1) > 2                              % 軌跡を線で表示
                    frame = insertShape(frame, 'Line', reshape(p',1,[]), 'color', 'red', 'SmoothEdges',false);
                  end
                end
                
                % マスク画像内に、四角枠を描画
                mask = insertObjectAnnotation(mask, 'rectangle', ...
                    bboxes, labels);
                % マスク画像内に、centroidsを＋で表示
                mask = insertMarker(mask, centroids, 'plus');     % 緑色 (検出された全物体の中心点)
            end
        end
        
        % 表示
        obj.videoPlayer.step(frame);          % RGBフレームの表示
        obj.maskPlayer.step(mask);           % マスクの表示
        
  drawnow;             % プッシュボタンのイベントの確認
end


% Copyright 2014 The MathWorks, Inc.

release(obj.reader);
release(obj.videoPlayer);
release(obj.maskPlayer);
release(obj.detector);

