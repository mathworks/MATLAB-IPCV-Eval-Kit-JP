%% Velodyne LiDAR PCAP(Point Capture)ファイルの読み込み

%% 初期化
clear; close all; clc;

%% Velodyne PCAPのファイルリーダーを定義
veloReader = velodyneFileReader('lidarData_ConstructionRoad.pcap','HDL32E');

%% ポイントクラウドプレイヤーを設定

% 表示範囲を設定
xlimits = [-60 60];
ylimits = [-60 60];
zlimits = [-20 20];

player = pcplayer(xlimits,ylimits,zlimits);

% 軸のラベル
xlabel(player.Axes,'X (m)');
ylabel(player.Axes,'Y (m)');
zlabel(player.Axes,'Z (m)');

%% 点群を読み出しながら表示

% 読み出し時刻を設定
veloReader.CurrentTime = veloReader.StartTime + seconds(0.3); 
while(hasFrame(veloReader) && player.isOpen() && (veloReader.CurrentTime < veloReader.StartTime + seconds(10)))
    % 点群読み出し
    ptCloudObj = readFrame(veloReader);
    
    % 点群表示
    view(player,ptCloudObj.Location,ptCloudObj.Intensity);
    
    % 0.1秒待機(より厳密に表示をしたい場合はfixed rateでtimerを使用すること)
    pause(0.1);
end

%%
% Copyright 2018 The MathWorks, Inc.
