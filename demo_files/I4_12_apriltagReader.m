%% AprilTagの検出 %%
clc;clear;close all;imtool close all;

%% 画像の読み込み
I = imread("aprilTagsMulti.jpg");
imshow(I)

%% AprilTagの読み取り

% タグのフォーマットを指定
tagFamily = ["tag36h11","tagCircle21h7","tagCircle49h12","tagCustom48h12","tagStandard41h12"];

% AprilTagの読み取り
[id,loc,detectedFamily] = readAprilTag(I,tagFamily);

% 結果の表示
centers = permute(mean(loc),[3 2 1]); % 中心座標の計算
I2 = insertText(I,centers, id, 'FontSize', 46);
imshow(I2)



%% AprilTagによる姿勢推定 %%

%% 画像の読み込み
I = imread('aprilTag36h11.jpg');
imshow(I)

%% レンズの歪み補正
% カメラキャリブレーションで抽出したカメラの内部パラメータを取り込み
data = load("camIntrinsicsAprilTag.mat");
intrinsics = data.intrinsics;

% 歪みの補正
tagSize = 0.04; % タグのサイズを指定
Iundistorted = undistortImage(I,intrinsics,"OutputView","same");
montage({I,Iundistorted})

%% AprilTagの読み取りと姿勢推定
[id,loc,pose] = readAprilTag(Iundistorted,"tag36h11",intrinsics,tagSize);

%% 結果の可視化

% タグ上に配置する直方体のサイズを指定
t = tagSize/2;
cubePoints = [-t -t    0; -t t    0; t t    0; t -t    0;...
              -t -t -2*t; -t t -2*t; t t -2*t; t -t -2*t];
worldPoints = [0 0 0;t 0 0; 0 t 0; 0 0 t];

for i = 1:length(pose)
    % 直方体に関する画像の座標を取得
    imagePoints = worldToImage(intrinsics,pose(i).Rotation, ...
                  pose(i).Translation,cubePoints);

    % 直方体の描写
    Iundistorted = insertShape(Iundistorted,"Line",cubeLines(imagePoints),"LineWidth",7,"Color","green");
    Iundistorted = insertText(Iundistorted,loc(1,:,i),id(i),"BoxOpacity",1,"FontSize",28);

end
imshow(Iundistorted)

function lines = cubeLines(impts)
    p1 = impts(1,:);
    p2 = impts(2,:);
    p3 = impts(3,:);
    p4 = impts(4,:);
    p5 = impts(5,:);
    p6 = impts(6,:);
    p7 = impts(7,:);
    p8 = impts(8,:);
    
    lines = ...
            [p1 p2; p2 p3; p3 p4; p4 p1;...
             p5 p6; p6 p7; p7 p8; p8 p5;...
             p1 p5; p2 p6; p3 p7; p4 p8];
end

%% Copyright 2020 The MathWorks, Inc.