%% 単眼カメラによるVisual SLAM
% ORB-SLAMによる動画からカメラ軌跡と点群マップの推定
% 詳細な動作に関しては下記URLの例題を参照
% https://www.mathworks.com/help/releases/R2020a/vision/examples/monocular-visual-simultaneous-localization-and-mapping.html


% 実行に必要なサポート関数へのパスを追加
addpath(fullfile(matlabroot,'examples\vision\main'));


%% 動画データのダウンロード
baseDownloadURL = 'https://vision.in.tum.de/rgbd/dataset/freiburg3/rgbd_dataset_freiburg3_long_office_household.tgz'; 
dataFolder      = fullfile(tempdir, 'tum_rgbd_dataset', filesep); 
options         = weboptions('Timeout', Inf);
tgzFileName     = [dataFolder, 'fr3_office.tgz'];
folderExists    = exist(dataFolder, 'dir');

% データのダウンロード
if ~folderExists  
    mkdir(dataFolder); 
    disp('Downloading fr3_office.tgz (1.38 GB). This download can take a few minutes.') 
    websave(tgzFileName, baseDownloadURL, options); 
    
    % Extract contents of the downloaded file
    disp('Extracting fr3_office.tgz (1.38 GB) ...') 
    untar(tgzFileName, dataFolder); 
end
imageFolder   = [dataFolder,'rgbd_dataset_freiburg3_long_office_household/rgb/'];
imds          = imageDatastore(imageFolder);

% 最初のフレーム画像の確認
currFrameIdx = 1;
currI = readimage(imds, currFrameIdx);
himage = imshow(currI);


%% マップの初期化
% 最初のフレームを1番目のキーフレームとし、カメラ姿勢推定に十分なマッチング点
% が得られるまで次フレームを読み込み。
% 十分なマッチング点が得られたフレームを2番目のキーフレームとする。

rng(0); % ランダムシードの設定

% カメラ内部パラメータの設定（読み込んだ画像は全て補正済み）
focalLength    = [535.4, 539.2];    % in units of pixels
principalPoint = [320.1, 247.6];    % in units of pixels
imageSize      = size(currI,[1 2]);  % in units of pixels
intrinsics     = cameraIntrinsics(focalLength, principalPoint, imageSize);

% ORB特徴検出と特徴量抽出
scaleFactor = 1.2;
numLevels   = 8;
[preFeatures, prePoints] = helperDetectAndExtractFeatures(currI, scaleFactor, numLevels); 

currFrameIdx = currFrameIdx + 1;
firstI       = currI; % 最初のフレームを保存

isMapInitialized  = false;

% マップの初期化
while ~isMapInitialized && currFrameIdx < numel(imds.Files)
    
    % 1フレーム読み込み
    currI = readimage(imds, currFrameIdx);
    
    % ORB特徴量の検出と抽出
    [currFeatures, currPoints] = helperDetectAndExtractFeatures(currI, scaleFactor, numLevels); 

    % インデックスを一つ進める
    currFrameIdx = currFrameIdx + 1;
    
    % 特徴のマッチング推定
    indexPairs = matchFeatures(preFeatures, currFeatures, 'Unique', true, ...
        'MaxRatio', 0.9, 'MatchThreshold', 40);
 
    preMatchedPoints  = prePoints(indexPairs(:,1),:);
    currMatchedPoints = currPoints(indexPairs(:,2),:);
    
    % 十分なマッチング点数が得られなかった場合は次フレームの処理へ
    minMatches = 100;
    if size(indexPairs, 1) < minMatches
        continue
    end
    
    % 十分なマッチング点数が得られたら、前後のマッチング点を登録
    preMatchedPoints  = prePoints(indexPairs(:,1),:);
    currMatchedPoints = currPoints(indexPairs(:,2),:);
    
    % ホモグラフィーの計算と再構築の評価
    [tformH, scoreH, inliersIdxH] = helperComputeHomography(preMatchedPoints, currMatchedPoints);

    % 基礎行列の計算と再構築の評価
    [tformF, scoreF, inliersIdxF] = helperComputeFundamentalMatrix(preMatchedPoints, currMatchedPoints);
    
    % スコアが高い方の手法を変換行列に使用
    ratio = scoreH/(scoreH + scoreF);
    ratioThreshold = 0.45;
    if ratio > ratioThreshold
        inlierTformIdx = inliersIdxH;
        tform          = tformH;
    else
        inlierTformIdx = inliersIdxF;
        tform          = tformF;
    end

    % カメラ位置の計算（処理速度向上の為、半分のインライアを使用）
    inlierPrePoints  = preMatchedPoints(inlierTformIdx);
    inlierCurrPoints = currMatchedPoints(inlierTformIdx);
    [relOrient, relLoc, validFraction] = relativeCameraPose(tform, intrinsics, ...
        inlierPrePoints(1:2:end), inlierCurrPoints(1:2:end));
    
    % 十分なインライアが得られなかった場合は次フレームの処理へ
    if validFraction < 0.9 || numel(size(relOrient))==3
        continue
    end
    
    % 三角法で3Dマップ点を計算
    relPose = rigid3d(relOrient, relLoc);
    minParallax = 3; % In degrees
    [isValid, xyzWorldPoints, inlierTriangulationIdx] = helperTriangulateTwoFrames(...
        rigid3d, relPose, inlierPrePoints, inlierCurrPoints, intrinsics, minParallax);
    
    if ~isValid
        continue
    end
    
    % 2つのキーフレームにおける特徴点のインデックスを取得
    indexPairs = indexPairs(inlierTformIdx(inlierTriangulationIdx),:);
    
    isMapInitialized = true;
    
    disp(['Map initialized with frame 1 and frame ', num2str(currFrameIdx-1)])
end 

if isMapInitialized
    close(himage.Parent.Parent); % 前回のFigureを閉じる
    % マッチした特徴点を表示
    hfeature = showMatchedFeatures(firstI, currI, prePoints(indexPairs(:,1)), ...
        currPoints(indexPairs(:, 2)), 'Montage');
else
    error('Unable to initialize map.')
end


%% キーフレームとマップ点の管理用オブジェクトの作成

% imageviewsetオブジェクトを使用してキーフレームを管理
vSetKeyFrames = imageviewset;

% 3Dマップ点を保存するworldpointsetオブジェクトを作成
mapPointSet   = worldpointset;

% 向きと奥行きを保持するhelperViewDirectionAndDepthオブジェクト 
directionAndDepth = helperViewDirectionAndDepth(size(xyzWorldPoints, 1));

% 1番目のキーフレームを保存
preViewId     = 1;
vSetKeyFrames = addView(vSetKeyFrames, preViewId, rigid3d, 'Points', prePoints,...
    'Features', preFeatures.Features);

% 2番目のキーフレームを保存
currViewId    = 2;
vSetKeyFrames = addView(vSetKeyFrames, currViewId, relPose, 'Points', currPoints,...
    'Features', currFeatures.Features);

% 1番目と2番目のキーフレームの接続情報を追加
vSetKeyFrames = addConnection(vSetKeyFrames, preViewId, currViewId, relPose, 'Matches', indexPairs);

% 3Dマップ点の追加
[mapPointSet, newPointIdx] = addWorldPoints(mapPointSet, xyzWorldPoints);

% マップ点の観測情報を追加
preLocations   = prePoints.Location;
currLocations  = currPoints.Location;
preScales      = prePoints.Scale;
currScales     = currPoints.Scale;

% 1番目のキーフレームにおける3Dマップ点に一致する画像点を追加
mapPointSet   = addCorrespondences(mapPointSet, preViewId, newPointIdx, indexPairs(:,1));

% 2番目のキーフレームにおける3Dマップ点に一致する画像点を追加
mapPointSet   = addCorrespondences(mapPointSet, currViewId, newPointIdx, indexPairs(:,2));


%% 最初のバンドル調整と結果の可視化

% ここまでで得られた2つのキーフレームでバンドル調整を実行
tracks       = findTracks(vSetKeyFrames);
cameraPoses  = poses(vSetKeyFrames);

[refinedPoints, refinedAbsPoses] = bundleAdjustment(xyzWorldPoints, tracks, ...
    cameraPoses, intrinsics, 'FixedViewIDs', 1, ...
    'PointsUndistorted', true, 'AbsoluteTolerance', 1e-7,...
    'RelativeTolerance', 1e-15, 'MaxIteration', 50);

% マップ点の奥行きの中央値を使ってマップとカメラ位置をスケーリング
medianDepth   = median(vecnorm(refinedPoints.'));
refinedPoints = refinedPoints / medianDepth;

refinedAbsPoses.AbsolutePose(currViewId).Translation = ...
    refinedAbsPoses.AbsolutePose(currViewId).Translation / medianDepth;
relPose.Translation = relPose.Translation/medianDepth;

% 調整後の位置でキーフレームを更新
vSetKeyFrames = updateView(vSetKeyFrames, refinedAbsPoses);
vSetKeyFrames = updateConnection(vSetKeyFrames, preViewId, currViewId, relPose);

% 調整後の位置でマップ点を更新
mapPointSet   = updateWorldPoints(mapPointSet, newPointIdx, refinedPoints);

% 向きと奥行きの更新
directionAndDepth = update(directionAndDepth, mapPointSet, vSetKeyFrames.Views, newPointIdx, true);

% 現在のフレームでマッチした特徴点を可視化
close(hfeature.Parent.Parent);
featurePlot   = helperVisualizeMatchedFeatures(currI, currPoints(indexPairs(:,2)));

% 初期のマップ点とカメラの軌跡を可視化
mapPlot       = helperVisualizeMotionAndStructure(vSetKeyFrames, mapPointSet);
showLegend(mapPlot);


%% トラッキング・地図作成と局所的な最適化（Local Mapping）・Loop Closure

% 現在のキーフレームのViewId
currKeyFrameId    = currViewId;

% 最後のキーフレームのViewId
lastKeyFrameId    = currViewId;

% 共視認性が最も高いマップ点を保持した参照キーフレームのViewId
refKeyFrameId     = currViewId;

% 入力画像シーケンスにおける最後のキーフレームのインデックス
lastKeyFrameIdx   = currFrameIdx - 1; 

% 入力画像シーケンスにおける全てのキーフレームのインデックス
addedFramesIdx    = [1; lastKeyFrameIdx];

isLoopClosed      = false;

% Main loop
while ~isLoopClosed && currFrameIdx < numel(imds.Files)  
    currI = readimage(imds, currFrameIdx);
    
  
    % ==============
    % Tracking
    % ==============   
    
    % ORB特徴量の検出と抽出
    [currFeatures, currPoints] = helperDetectAndExtractFeatures(currI, scaleFactor, numLevels);

    % 最後のキーフレームのトラック
    % mapPointsIdx:   現在のフレームで観測されたマップ点のインデックス
    % featureIdx:     現在のフレームと一致する特徴のインデックス
    [currPose, mapPointsIdx, featureIdx] = helperTrackLastKeyFrame(mapPointSet, ...
        vSetKeyFrames.Views, currFeatures, currPoints, lastKeyFrameId, intrinsics, scaleFactor);

    % ローカルマップのトラック
    % refKeyFrameId:      現在のフレームとの共視認性が最も高い参照キーフレームのViewId
    % localKeyFrameIds:   現在のフレームと接続するキーフレームのViewId
    [refKeyFrameId, localKeyFrameIds, currPose, mapPointsIdx, featureIdx] = ...
        helperTrackLocalMap(mapPointSet, directionAndDepth, vSetKeyFrames, mapPointsIdx, ...
        featureIdx, currPose, currFeatures, currPoints, intrinsics, scaleFactor, numLevels);
   
    % 現在のフレームがキーフレームか確認 
    % ※下記の2条件を同時に満たす場合にキーフレームとする
    %
    % 1. 最後のキーフレームから少なくとも20フレーム経過しているか、
    %    80個のマップ点より現在のフレームのトラック数が少ない。 
    %
    % 2. 現在のフレームでトラックしたマップ点の数が、
    %    参照キーフレームによるトラックの数の90%より少ない。
    isKeyFrame = helperIsKeyFrame(mapPointSet, refKeyFrameId, lastKeyFrameIdx, ...
        currFrameIdx, mapPointsIdx);
    
    % マッチした特徴点の可視化
    updatePlot(featurePlot, currI, currPoints(featureIdx));
    
    % キーフレームでなかった場合は次のフレーム処理へ
    if ~isKeyFrame
        currFrameIdx = currFrameIdx + 1;
        continue
    end
    
    % 現在のキーフレームIDの更新
    currKeyFrameId  = currKeyFrameId + 1;

    % ==============
    % Local Mapping
    % ==============
    
    % 新しいキーフレームの追加 
    [mapPointSet, vSetKeyFrames] = helperAddNewKeyFrame(mapPointSet, vSetKeyFrames, ...
        currPose, currFeatures, currPoints, mapPointsIdx, featureIdx, localKeyFrameIds);
    
    % 3キーフレーム未満で観察されたマップ点の外れ値を削除
    [mapPointSet, directionAndDepth, mapPointsIdx] = helperCullRecentMapPoints(mapPointSet, directionAndDepth, mapPointsIdx, newPointIdx);
       
    % 三角法により新しいマップ点を作成
    minNumMatches = 20;
    minParallax = 3;
    [mapPointSet, vSetKeyFrames, newPointIdx] = helperCreateNewMapPoints(mapPointSet, vSetKeyFrames, ...
        currKeyFrameId, intrinsics, scaleFactor, minNumMatches, minParallax);

    % 方向と奥行きの更新
    directionAndDepth = update(directionAndDepth, mapPointSet, vSetKeyFrames.Views, [mapPointsIdx; newPointIdx], true);

    
    % 局所的なバンドル調整
    [mapPointSet, directionAndDepth, vSetKeyFrames, newPointIdx] = helperLocalBundleAdjustment(mapPointSet, directionAndDepth, vSetKeyFrames, ...
        currKeyFrameId, intrinsics, newPointIdx); 
    
    % カメラの軌跡を3次元上で可視化
    updatePlot(mapPlot, vSetKeyFrames, mapPointSet);

    % ==============
    % Loop Closure
    % ==============
    
    % ループクロージャーのデータベースを初期化
    if currKeyFrameId == 3
        % 別途用意しておいたBag Of Featuresのデータを読み込み
        bofData         = load('bagOfFeaturesData.mat');
        loopDatabase    = invertedImageIndex(bofData.bof);
        loopCandidates  = [1; 2];
        
    % いくつかのキーフレームの作成後、ループクロージャを確認  
    elseif currKeyFrameId > 20
        
        % ループエッジにおける最小の特徴一致数
        loopEdgeNumMatches = 50;
        
        % ループクロージャ可能なキーフレーム候補の検出
        [isDetected, validLoopCandidates] = helperCheckLoopClosure(vSetKeyFrames, currKeyFrameId, ...
            loopDatabase, currI, loopCandidates, loopEdgeNumMatches);
        
        if isDetected 
            % ループクロージャの接続を追加
            [isLoopClosed, mapPointSet, vSetKeyFrames] = helperAddLoopConnections(...
                mapPointSet, vSetKeyFrames, validLoopCandidates, currKeyFrameId, ...
                currFeatures, currPoints, intrinsics, scaleFactor, loopEdgeNumMatches);
        end
    end
    
    % ループクロージャが検出できなかった場合はデータベースに画像を追加
    if ~isLoopClosed
        currds = imageDatastore(imds.Files{currFrameIdx});
        addImages(loopDatabase, currds, 'Verbose', false);
        loopCandidates= [loopCandidates; currKeyFrameId];
    end
    
    % 各種IDとインデックスを更新
    lastKeyFrameId  = currKeyFrameId;
    lastKeyFrameIdx = currFrameIdx;
    addedFramesIdx  = [addedFramesIdx; currFrameIdx];
    currFrameIdx  = currFrameIdx + 1;
end 

%% 全てのキーフレームで最適化

% ポーズグラフの最適化
vSetKeyFramesOptim = optimizePoses(vSetKeyFrames, minNumMatches, 'Tolerance', 1e-16, 'Verbose', true);

% ポーズグラフの最適化後にマップ点を更新
mapPointSet = helperUpdateGlobalMap(mapPointSet, directionAndDepth, ...
    vSetKeyFrames, vSetKeyFramesOptim);

updatePlot(mapPlot, vSetKeyFrames, mapPointSet);

% 最適化されたカメラ軌跡のプロット
optimizedPoses  = poses(vSetKeyFramesOptim);
plotOptimizedTrajectory(mapPlot, optimizedPoses)
showLegend(mapPlot);

%% Ground Truthデータとの比較
% データの読み込み
gTruthData = load('orbslamGroundTruth.mat');
gTruth     = gTruthData.gTruth;

% 実際のカメラ軌跡をプロット 
plotActualTrajectory(mapPlot, gTruth(addedFramesIdx), optimizedPoses);
showLegend(mapPlot);

% トラッキング精度を評価
helperEstimateTrajectoryError(gTruth(addedFramesIdx), optimizedPoses);



%% サポート関数

function [features, validPoints] = helperDetectAndExtractFeatures(Irgb, ...
    scaleFactor, numLevels, varargin)

numPoints   = 1000;

% In this example, the images are already undistorted. In a general
% workflow, uncomment the following code to undistort the images.
%
% if nargin > 3
%     intrinsics = varargin{1};
% end
% Irgb  = undistortImage(Irgb, intrinsics);

% Detect ORB features
Igray  = rgb2gray(Irgb);

points = detectORBFeatures(Igray, 'ScaleFactor', scaleFactor, 'NumLevels', numLevels);

% Select a subset of features, uniformly distributed throughout the image
points = selectUniform(points, numPoints, size(Igray, 1:2));

% Extract features
[features, validPoints] = extractFeatures(Igray, points);
end
%% 
% |*helperHomographyScore*| compute homography and evaluate reconstruction.

function [H, score, inliersIndex] = helperComputeHomography(matchedPoints1, matchedPoints2)

[H, inliersLogicalIndex] = estimateGeometricTransform2D( ...
    matchedPoints1, matchedPoints2, 'projective', ...
    'MaxNumTrials', 1e3, 'MaxDistance', 4, 'Confidence', 90);

inlierPoints1 = matchedPoints1(inliersLogicalIndex);
inlierPoints2 = matchedPoints2(inliersLogicalIndex);

inliersIndex  = find(inliersLogicalIndex);

locations1 = inlierPoints1.Location;
locations2 = inlierPoints2.Location;
xy1In2     = transformPointsForward(H, locations1);
xy2In1     = transformPointsInverse(H, locations2);
error1in2  = sum((locations2 - xy1In2).^2, 2);
error2in1  = sum((locations1 - xy2In1).^2, 2);

outlierThreshold = 6;

score = sum(max(outlierThreshold-error1in2, 0)) + ...
    sum(max(outlierThreshold-error2in1, 0));
end
%% 
% |*helperFundamentalMatrixScore*| compute fundamental matrix and evaluate reconstruction.

function [F, score, inliersIndex] = helperComputeFundamentalMatrix(matchedPoints1, matchedPoints2)

[F, inliersLogicalIndex]   = estimateFundamentalMatrix( ...
    matchedPoints1, matchedPoints2, 'Method','RANSAC',...
    'NumTrials', 1e3, 'DistanceThreshold', 0.01);

inlierPoints1 = matchedPoints1(inliersLogicalIndex);
inlierPoints2 = matchedPoints2(inliersLogicalIndex);

inliersIndex  = find(inliersLogicalIndex);

locations1    = inlierPoints1.Location;
locations2    = inlierPoints2.Location;

% Distance from points to epipolar line
lineIn1   = epipolarLine(F', locations2);
error2in1 = (sum([locations1, ones(size(locations1, 1),1)].* lineIn1, 2)).^2 ...
    ./ sum(lineIn1(:,1:2).^2, 2);
lineIn2   = epipolarLine(F, locations1);
error1in2 = (sum([locations2, ones(size(locations2, 1),1)].* lineIn2, 2)).^2 ...
    ./ sum(lineIn2(:,1:2).^2, 2);

outlierThreshold = 4;

score = sum(max(outlierThreshold-error1in2, 0)) + ...
    sum(max(outlierThreshold-error2in1, 0));

end
%% 
% |*helperTriangulateTwoFrames*| triangulate two frames to initialize the map.

function [isValid, xyzPoints, inlierIdx] = helperTriangulateTwoFrames(...
    pose1, pose2, matchedPoints1, matchedPoints2, intrinsics, minParallax)

[R1, t1]   = cameraPoseToExtrinsics(pose1.Rotation, pose1.Translation);
camMatrix1 = cameraMatrix(intrinsics, R1, t1);

[R2, t2]   = cameraPoseToExtrinsics(pose2.Rotation, pose2.Translation);
camMatrix2 = cameraMatrix(intrinsics, R2, t2);

[xyzPoints, reprojectionErrors, isInFront] = triangulate(matchedPoints1, ...
    matchedPoints2, camMatrix1, camMatrix2);

% Filter points by view direction and reprojection error
minReprojError = 1;
inlierIdx  = isInFront & reprojectionErrors < minReprojError;
xyzPoints  = xyzPoints(inlierIdx ,:);

% A good two-view with significant parallax
ray1       = xyzPoints - pose1.Translation;
ray2       = xyzPoints - pose2.Translation;
cosAngle   = sum(ray1 .* ray2, 2) ./ (vecnorm(ray1, 2, 2) .* vecnorm(ray2, 2, 2));

% Check parallax
isValid = all(cosAngle < cosd(minParallax) & cosAngle>0);
end
%% 
% |*helperIsKeyFrame*| check if a frame is a key frame.

function isKeyFrame = helperIsKeyFrame(mapPoints, ...
    refKeyFrameId, lastKeyFrameIndex, currFrameIndex, mapPointsIndices)

numPointsRefKeyFrame = numel(findWorldPointsInView(mapPoints, refKeyFrameId));

% More than 20 frames have passed from last key frame insertion
tooManyNonKeyFrames = currFrameIndex >= lastKeyFrameIndex + 20;

% Track less than 90 map points
tooFewMapPoints     = numel(mapPointsIndices) < 90;

% Tracked map points are fewer than 90% of points tracked by
% the reference key frame
tooFewTrackedPoints = numel(mapPointsIndices) < 0.9 * numPointsRefKeyFrame;

isKeyFrame = (tooManyNonKeyFrames || tooFewMapPoints) && tooFewTrackedPoints;
end
%% 
% |*helperCullRecentMapPoints*| cull recently added map points.

function [mapPointSet, directionAndDepth, mapPointsIdx] = helperCullRecentMapPoints(mapPointSet, directionAndDepth, mapPointsIdx, newPointIdx)
outlierIdx    = setdiff(newPointIdx, mapPointsIdx);
if ~isempty(outlierIdx)
    mapPointSet   = removeWorldPoints(mapPointSet, outlierIdx);
    directionAndDepth = remove(directionAndDepth, outlierIdx);
    mapPointsIdx  = mapPointsIdx - arrayfun(@(x) nnz(x>outlierIdx), mapPointsIdx);
end
end
%% 
% |*helperEstimateTrajectoryError* calculate| the tracking error.

function rmse = helperEstimateTrajectoryError(gTruth, cameraPoses)
locations       = vertcat(cameraPoses.AbsolutePose.Translation);
gLocations      = vertcat(gTruth.Translation);
scale           = median(vecnorm(gLocations, 2, 2))/ median(vecnorm(locations, 2, 2));
scaledLocations = locations * scale;

rmse = sqrt(mean( sum((scaledLocations - gLocations).^2, 2) ));
disp(['Absolute RMSE for key frame trajectory (m): ', num2str(rmse)]);
end
%%
% |*helperUpdateGlobalMap update 3-D locations of map points after pose graph optimization

function [mapPointSet, directionAndDepth] = helperUpdateGlobalMap(...
    mapPointSet, directionAndDepth, vSetKeyFrames, vSetKeyFramesOptim)
%helperUpdateGlobalMap update map points after pose graph optimization
posesOld     = vSetKeyFrames.Views.AbsolutePose;
posesNew     = vSetKeyFramesOptim.Views.AbsolutePose;
positionsOld = mapPointSet.WorldPoints;
positionsNew = positionsOld;
indices = 1:mapPointSet.Count;

% Update world location of each map point based on the new absolute pose of 
% the corresponding major view
for i = 1: mapPointSet.Count
    majorViewIds = directionAndDepth.MajorViewId(i);
    tform = posesOld(majorViewIds).T \ posesNew(majorViewIds).T ;
    positionsNew(i, :) = positionsOld(i, :) * tform(1:3,1:3) + tform(4, 1:3);
end
mapPointSet = updateWorldPoints(mapPointSet, indices, positionsNew);
end

%% _Copyright 2020 The MathWorks, Inc._