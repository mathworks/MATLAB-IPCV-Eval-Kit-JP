%% 初期化
clear;clc;close all;imtool close all

%% Step 1: トラッキングする顔を先ず検出
% 顔認識用オブジェクトの作成
faceDetector = vision.CascadeObjectDetector();

% 1フレーム読込み、顔検出を実行
videoFileReader = vision.VideoFileReader('visionface.avi');
videoFrame      = step(videoFileReader);
bbox            = step(faceDetector, videoFrame);

% 検出した顔の周りに四角を描画し、画像を表示
videoOut = insertObjectAnnotation(videoFrame,'rectangle',bbox,'Face');
figure, imshow(videoOut), title('Detected face');


%% Step 2: Identify Facial Features To Track
% Get the skin tone information by extracting the Hue from the video frame
% converted to the HSV color space.
% Hueチャネルで表示し、顔の周りに四角を描画
% 肌色をトラッキングする特徴として用いる。(顔が移動したり傾いても変わらない特徴量)
[hueChannel,~,~] = rgb2hsv(videoFrame);   % HSV空間へ変換
figure, imshow(hueChannel), title('Hue channel data');
rectangle('Position',bbox(1,:),'LineWidth',2,'EdgeColor',[1 1 0])


%% STEP3 : 顔をトラッキング
% 鼻の領域のHueヒストグラムでトラッキング(背景が含まれないため)
noseDetector = vision.CascadeObjectDetector('Nose');
faceImage    = imcrop(videoFrame,bbox(1,:));
noseBBox     = step(noseDetector,faceImage);

% The nose bounding box is defined relative to the cropped face image.
% Adjust the nose bounding box so that it is relative to the original video
% frame.
noseBBox(1,1:2) = noseBBox(1,1:2) + bbox(1,1:2);

% Create a tracker object.
tracker = vision.HistogramBasedTracker;

% trackerを、鼻領域のピクセルのHueで初期化
initializeObject(tracker, hueChannel, noseBBox(1,:));

% Create a video player object for displaying video frames.
videoInfo    = info(videoFileReader);
videoPlayer  = vision.VideoPlayer('Position',[300 300 videoInfo.VideoSize+30]);

% Track the face over successive video frames until the video is finished.
while ~isDone(videoFileReader)

    % １フレーム読込み
    videoFrame = step(videoFileReader);

    % 入力RGBを、HSVへ変換
    [hueChannel,~,~] = rgb2hsv(videoFrame);

    % 前フレームの鼻部分のHueヒストグラムを用い、トラッキング
    bbox = step(tracker, hueChannel);

    % Insert a bounding box around the object being tracked
    videoOut = insertObjectAnnotation(videoFrame,'rectangle',bbox,'Face');

    % Display the annotated video frame using the video player object
    step(videoPlayer, videoOut);

end

% Release resources
release(videoFileReader);
release(videoPlayer);

% Copyright 2014 The MathWorks, Inc.
