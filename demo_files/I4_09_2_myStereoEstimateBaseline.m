%% ステレオシステムのベースラインの推定

%% カメラの内部パラメータのロード
ld = load('wideBaselineStereo');
intrinsics1 = ld.intrinsics1;
intrinsics2 = ld.intrinsics2;

%% チェッカボードのサイズを指定
squareSize = 29; % 1マスのサイズをmmで指定

%% ステレオカメラキャリブレーターアプリを使ったベースラインの推定
% 「固定内部パラメーターの読み込み」を選択
% 「カメラ1の内部パラメーターの指定」にintrinsics1を指定
% 「カメラ2の内部パラメーターの指定」にintrinsics2を指定
stereoCameraCalibrator(...
    fullfile(toolboxdir('vision'),'visiondata','calibration','wideBaseline','left'),...
    fullfile(toolboxdir('vision'),'visiondata','calibration','wideBaseline','right'),...
    squareSize);

%% プログラムによるベースラインの推定

%% キャリブレーション用の画像を指定
leftImages = imageDatastore(fullfile(toolboxdir('vision'),'visiondata', ...
    'calibration','wideBaseline','left'));
rightImages = imageDatastore(fullfile(toolboxdir('vision'),'visiondata', ...
    'calibration','wideBaseline','right'));

%% チェッカーボードの検出
[imagePoints, boardSize] = ...
    detectCheckerboardPoints(leftImages.Files,rightImages.Files);
worldPoints = generateCheckerboardPoints(boardSize,squareSize);

%% ステレオベースラインと外部パラメータの推定
params = estimateStereoBaseline(imagePoints,worldPoints, ...
    intrinsics1,intrinsics2)

%% キャリブレーション精度の可視化
figure
showReprojectionErrors(params)

%% カメラの外部パラメータの可視化
figure
showExtrinsics(params)

%%
% Copyright 2018 The MathWorks, Inc.