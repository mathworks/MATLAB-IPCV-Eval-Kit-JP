%% 複数の2次元画像からの、Structure From Motion
%      キャリブレーション済みカメラで撮影された複数の時系列2次元画像から、
%      3次元構造の再構築、各画像に対応するカメラ位置･姿勢推定（スケールは不定）
% セクション#1：カメラ移動の推定（画像上の点の集合は疎なものを使用）
% セクション#2：密な3次元点群の再構成

clc;clear;close all;imtool close all; rng('default');

%% 時系列の複数画像のファイル指定（imageSetクラスを使用）
imageDir = [matlabroot '\toolbox\vision\visiondata\structureFromMotion'];
imds = imageDatastore(imageDir)

%% 画像の表示 (カメラが左方向へ回転)
figure; montage(imds.Files, 'Size', [1,5]); truesize;

%% 全画像の読込み
images = readall(imds);    % 5x1

%% [セクション#1：カメラ移動(位置･姿勢)の推定] %%%%%%%%%%%%%%%%%%%%
%  ＊viewSetオブジェクトを使用：
%        各画像での特徴点座標とカメラの位置･姿勢を格納 => vSet.Views         View数x[ViewId, Points, Orientation, Location]
%        各画像間の特徴点の対応を格納                  => vSet.Connections   View数-1 x[ViewId1, ViewId2, Matches, RelativeOrientation, RelativeLocation]
% 下記1～9を、全Viewに対し、Viewの順に実行
% 1: レンズ歪除去XS
% 2: 特徴点の検出、特徴量抽出、
% 3: 一つ前の画像と、2つの画像間で特徴量のマッチング（ポイントトラッカーでも可能）
% 4: 基本行列(2つの正規化画像座標上の点の対応関係)の推定
% 5: 2つの画像間の点の対応関係から、一つ前のカメラ位置･姿勢に対する位置･姿勢を推定
% 6: 最初のカメラ位置･姿勢に対する、現カメラ位置･姿勢を計算
% 7: トラック(複数Viewにまたがる、点の対応関係)の抽出
% 8: 現Viewまでの全カメラ位置･姿勢情報と全点対応関係を用い、各点の3次元位置(マップ)を推定
% 9: バンドル調整により、それまでの全点群座標と、カメラ位置･姿勢を修正

%% 1枚目の画像を処理
% 1枚目の画像のレンズ歪除去･表示
load([imageDir, '\cameraParams.mat']);   % カメラパラメータの読込み
I = undistortImage(images{1}, cameraParams); 
figure; imshowpair(images{1}, I, 'montage');truesize;

%%
% 周囲50ピクセルは除いて、特徴点抽出（画像エッジでの特徴点を排除）
border = 50;
roi = [border, border, size(I, 2)- 2*border, size(I, 1)- 2*border];
% 特徴点検出：大局的特長を取得する為に、NumOctavesを大きく設定
G = rgb2gray(I);      % グレースケールへ変換
prevPoints   = detectSURFFeatures(G, 'NumOctaves', 8, 'ROI', roi);
% 特徴量抽出：回転が少ないためUprightを指定(Orientationを上向きに固定)
prevFeatures = extractFeatures(G, prevPoints, 'Upright', true);

% 1枚目の画像のデータ(特徴点座標、カメラ位置･姿勢)を、viewID=1として登録
% このときのカメラ位置(光学中心)がWorld座標の原点
% カメラの向きがWorld座標系のZ軸の正方向
vSet = viewSet       % 空のviewSetオブジェクトを生成
viewID = 1;
vSet = addView(vSet, viewID, 'Points', prevPoints, 'Orientation', eye(3,'single'),...
                                      'Location', single([0 0 0]));           % Pointの型に揃える
vSet.Views     % ViewId=1 が登録されている

%% 残りの画像のデータも、ループ処理でvSetオブジェクトへ登録
for viewID = 2:numel(images)
    % レンズ歪除去
    I = undistortImage(images{viewID}, cameraParams);
    
    % 特徴点検出･特徴量抽出･一つ前の画像の特徴量とマッチング
    G = rgb2gray(I);       % グレースケールへ変換
    currPoints   = detectSURFFeatures(G, 'NumOctaves', 8, 'ROI', roi);
    currFeatures = extractFeatures(G, currPoints, 'Upright', true);    
    indexPairs = matchFeatures(prevFeatures, currFeatures, ...
                           'MaxRatio', .7, 'Unique',  true);
    
    % 対応関係が見つかった特徴点を抽出
    matchedPoints1 = prevPoints(indexPairs(:, 1));
    matchedPoints2 = currPoints(indexPairs(:, 2));
    
    % 対応点の情報から
    % 一つ前のカメラ位置･姿勢(カメラ座標)に対する位置･姿勢を推定（距離は1と仮定）
    % 後のBundle Adjustmentで、距離の誤差等は補正される
    for i = 1:100
        % 基本行列(2つの画像の対応関係)の推定   
        [E, inlierIdx] = estimateEssentialMatrix( ...
            matchedPoints1, matchedPoints2, cameraParams);

        % inlierが少ない場合は、再度推定
        if sum(inlierIdx) / numel(inlierIdx) < .3
            continue;
        end
    
        % エピポーラ拘束を満たさないもの(誤対応点)の除去
        inlierPoints1 = matchedPoints1(inlierIdx, :);
        inlierPoints2 = matchedPoints2(inlierIdx, :);    
    
        % 基本行列から、一つ前のカメラ位置･姿勢に対する、現カメラ位置(単位ベクトル)・姿勢を推定
        [relativeOrient, relativeLoc, validPointFraction] = ...
            relativeCameraPose(E, cameraParams, inlierPoints1, inlierPoints2);         % ポイントを半分に間引くことで処理の高速化も可能 (1:2:end, :)

        % 有効な点の割合が高くなるまで繰り返し、基本行列の推定を行う
        if validPointFraction > .8
            break;
        elseif i == 100;
            % 100回反復してもvalidPointFractionが低い場合は、エラーにする
            error('Unable to compute the Essental matrix');
        end  
    end

    % 1つ前のカメラ位置･姿勢(ワールド座標系)を取得 (addView でセットしたもの)
    prevPose = poses(vSet, viewID-1);
    prevOrientation = prevPose.Orientation{1};
    prevLocation    = prevPose.Location{1};           
    % 一番目のViewに対する(ワールド座標系)、現カメラ位置･姿勢を求める.
    orientation = relativeOrient * prevOrientation;
    location    = relativeLoc    * prevOrientation + prevLocation;

    % 特徴点の座標、カメラ位置･姿勢を、vSetへ登録
    vSet = addView(vSet, viewID, 'Points', currPoints, 'Orientation', orientation, ...
        'Location', location);
    % 一つ前の画像との特徴点の対応関係を、vSetへ登録
    vSet = addConnection(vSet, viewID-1, viewID, 'Matches', indexPairs(inlierIdx,:));

    % トラック：複数Viewにまたがる、点の全対応関係情報（一部のトラックは、全Viewにまたがっている）
    tracks1 = findTracks(vSet);  % 現在までの全View間のトラック情報抽出

    % 現在までの全Viewの、カメラ位置･姿勢を取得
    camPoses1 = poses(vSet);

    % 複数画像上の点対応関係から、各点の3次元位置を推定
    xyzPoints1 = triangulateMultiview(tracks1, camPoses1, cameraParams);
    
    % Bundle Adjustmentで、点群の位置とカメラ位置･姿勢を最適化する
    [xyzPoints1, camPoses1, reprojectionErrors] = bundleAdjustment(xyzPoints1, ...
             tracks1, camPoses1, cameraParams, 'FixedViewId', 1, ...
             'PointsUndistorted', true);

    % バンドル調整で微修正したカメラ位置･姿勢を登録
    vSet = updateView(vSet, camPoses1);       % テーブル：camPoses1 の情報（ViewID, Orientation, Location）でアップデート

    prevFeatures = currFeatures;
    prevPoints   = currPoints;  
end

%% 結果の確認
vSet.Views        % 各画像(View)での、特徴点座標、カメラ姿勢・位置
vSet.Connections  % 各画像間の点の対応関係

figure;   % 最後の2枚の画像間の対応関係（遠方のものは、移動量大）
showMatchedFeatures(undistortImage(images{viewID-1}, cameraParams), I, inlierPoints1, inlierPoints2); truesize;

%% プロット：3次元点群、カメラ位置･姿勢
camPoses1 = poses(vSet);
figure; plotCamera(camPoses1, 'Size', 0.2);  % カメラをFigure上にプロット
hold on;

goodIdx = (reprojectionErrors < 5);  % エラー値の大きい点を除去
pcshow(xyzPoints1(goodIdx, :), 'VerticalAxis', 'y', 'VerticalAxisDir', 'down', 'MarkerSize', 45);

xlim([-6 4]); ylim([-4 5]); zlim([-1 21]);
xlabel('X');ylabel('Y');zlabel('Z'); camorbit(0, -30); grid on; box on; hold off
title('Refined Camera Poses');

%% [セクション#2：再度全ての画像を処理し、密な3次元点群を再構成] %%%%%%%
%  一枚目の画像で密なコーナー点検出、その後ポイントトラッカーで全View上で対応位置を検出
% 複数画像上の対応点情報を用い3次元再構築
% 再度バンドル調整で、3次元点群座標と、カメラ位置･姿勢を微調整

% 一枚目の画像のレンズ歪除去
I = undistortImage(images{1}, cameraParams); 
% コーナー点検出（MinQualityを下げて、数を増やす）
G = rgb2gray(I);
initPoints = detectMinEigenFeatures(G, 'MinQuality', 0.001);

% トラッキング用オブジェクトを生成（トラッキングで、次の画像上の対応点を検出)
tracker = vision.PointTracker('MaxBidirectionalError', 1, 'NumPyramidLevels', 6);
% 検出されたコーナー点で、ポイントトラッカーを初期化
initPoints = initPoints.Location;
initialize(tracker, initPoints, I);

% 点対応関係を初期化後、密なコーナー点で特徴点座標を更新、
viewID = 1;
vSet = updateConnection(vSet, viewID, viewID+1, 'Matches', zeros(0, 2));
vSet = updateView(vSet, viewID, 'Points', initPoints);

%% 2枚目以降の画像上の対応点座標を、ポイントトラッカーで推定
%    vSetの、ViewとConnection情報をアップデート
for viewID = 2:numel(images)
    % 現画像から、レンズ歪の除去
    I = undistortImage(images{viewID}, cameraParams); 
    
    % 現画像上の対応点を検出
    [currPoints, validIdx] = step(tracker, I);
    
    % 点対応関係を初期化後、密なコーナー点で特徴点座標情報を更新、
    if viewID < numel(images)
        vSet = updateConnection(vSet, viewID, viewID+1, 'Matches', zeros(0, 2));
    end
    vSet = updateView(vSet, viewID, 'Points', currPoints);
    
    % 点対応関係情報を更新
    matches = repmat((1:size(initPoints, 1))', [1, 2]);
    matches = matches(validIdx, :);        
    vSet = updateConnection(vSet, viewID-1, viewID, 'Matches', matches);
end

% 結果の確認
vSet.Connections                                             % 有効点が徐々に減少：ポイントトラッカーを最初の画像で初期化しているため

% トラック：View間の点の対応関係情報、一部のトラックは、全Viewにまたがっている
tracks2 = findTracks(vSet);      % 全View間のトラック情報の抽出: 各トラック:存在するView(画像)番号と、各画像上の座標

% 全Viewの、カメラ位置･姿勢を取得
camPoses2 = poses(vSet);         % viewSetのメソッド

% 複数画像上の対応点組（トラック）に対応する、各点の3次元ワールド座標を計算
xyzPoints2 = triangulateMultiview(tracks2, camPoses2, cameraParams);

% 全Viewの、3次元点群座標とカメラ位置･姿勢をバンドル調整で微修正
[xyzPoints2, camPoses2, reprojectionErrors] = bundleAdjustment(...
    xyzPoints2, tracks2, camPoses2, cameraParams, 'FixedViewId', 1, 'PointsUndistorted', true);

%% 密な3次元再構成結果の表示
figure; plotCamera(camPoses2, 'Size',0.2);   % カメラ位置･姿勢をプロット
hold on;

% 各トラックの色を抽出
color = zeros(numel(tracks2),3,'uint8');
for k = 1:numel(tracks2)                        % 全トラックをループ処理
    Itracked = images{tracks2(k).ViewIds(1)};   % 各トラックの最初のViewIdの画像を選択 => RGB値を抽出
    x = round(tracks2(k).Points(1,1));
    y = round(tracks2(k).Points(1,2));
    x = min(size(Itracked,2),x);
    y = min(size(Itracked,1),y);
    color(k,:) = Itracked(y,x,:);
end

goodIdx = (reprojectionErrors < 5);  % エラー値が大きい点を除去
pcshow(xyzPoints2(goodIdx, :), color(goodIdx, :), 'VerticalAxis', 'y', 'VerticalAxisDir', 'down', 'MarkerSize', 20);

xlim([-6 4]); ylim([-4 5]); zlim([-1 21]);
xlabel('X');ylabel('Y');zlabel('Z');camorbit(0, -30); grid on; box on;
title('Dense Reconstruction');

%% 終了













%% カメラ移動量が既知の場合、絶対距離の点群に変換
     camPoses2.Location{1}    % カメラ位置1の座標は、[0 0 0]
p5 = camPoses2.Location{5}    % カメラ位置5の座標（カメラ1からの相対座標）
scaleFactor = 2.1 / norm(p5)  % [例] カメラ位置1とカメラ位置5の距離が、2.1mのとき

xyzPointsS = xyzPoints2 * scaleFactor;     % 点群のスケールを変更

camPosesS  = camPoses2;
locS =cell2mat(camPosesS.Location) * scaleFactor
camPosesS.Location = num2cell(locS, 2)

% 表示
figure; plotCamera(camPosesS, 'Size',0.2);   % カメラ位置･姿勢をプロット
hold on;
pcshow(xyzPointsS(goodIdx, :), color(goodIdx, :), 'VerticalAxis', 'y', 'VerticalAxisDir', 'down', 'MarkerSize', 20);
xlim([-6 4]); ylim([-4 5]); zlim([-1 21]);
xlabel('X');ylabel('Y');zlabel('Z');camorbit(0, -30); grid on; box on;
title('Dense Reconstruction (Actual Scale)');


%% カメラパラメータを、数値で指定する場合 %%%%%%%%%%%%
%load([imageDir, '\cameraParams.mat'])   の代わりに

% 内部カメラパラメータの設定
intrinsicMatrix = [1037.575214664696                  0  0;
                      0               1043.315752317925  0;
                   642.231583031218   387.835775096238    1];
% レンズ歪パラメータの設定
radialDistortion = [0.146911684283474  -0.214389634520344];
% cameraParameters オブジェクトの生成
cameraParams = cameraParameters('IntrinsicMatrix',intrinsicMatrix, 'RadialDistortion',radialDistortion);


%% Copyright 2016 The MathWorks, Inc. 
