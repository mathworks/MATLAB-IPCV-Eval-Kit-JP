%% LiDARの点群データから路面検出

%% Velodyne PCAPファイルリーダーを定義
velodyneFileReaderObj = velodyneFileReader('lidardata_ConstructionRoad.pcap','HDL32E');

%% pcplayerを定義
xlimits = [-40 40];
ylimits = [-15 15];
zlimits = [-3 3];
player = pcplayer(xlimits,ylimits,zlimits);
xlabel(player.Axes,'X (m)')
ylabel(player.Axes,'Y (m)')
zlabel(player.Axes,'Z (m)')

%% カラーマップを定義
colors = [0 1 0; 1 0 0]; % 緑と赤
greenIdx = 1; % 緑のインデックス
redIdx = 2; % 赤のインデックス
colormap(player.Axes,colors)
title(player.Axes,'Segmented Ground Plane of Lidar Point Cloud');

%% 最初の200点群を路面検出し、結果を表示
for i = 1 : 200
    % 現在の点群を読み込み
    ptCloud = velodyneFileReaderObj.readFrame(i);
    
    % ラベル行列作成
    colorLabels = zeros(size(ptCloud.Location,1),size(ptCloud.Location,2));
    
    % 路面検出
    groundPtsIdx = segmentGroundFromLidarData(ptCloud);
    
    % 路面を緑のインデックスにする
    colorLabels(groundPtsIdx (:)) = greenIdx;
    % 路面以外を赤のインデックスにする
    colorLabels(~groundPtsIdx (:)) = redIdx;
    
    % 結果の可視化
    view(player,ptCloud.Location,colorLabels)
end

%%
% Copyright 2018 The MathWorks, Inc.