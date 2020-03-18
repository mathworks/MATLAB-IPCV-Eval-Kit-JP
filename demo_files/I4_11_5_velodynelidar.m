%% Velodyne LiDAR(R)デバイスから点群の取得

%% velodynelidarオブジェクトの定義
lidar = velodynelidar('VLP16');

% ポート指定の場合
% v = velodynelidar('HDL32E','Port',3000) 

% キャリブレーションファイル指定の場合
% v = velodynelidar('HDL32E','CalibrationFile','C:\utilities\velodyneFileReaderConfiguration\VLP32C.xml)'

% Model Value	Velodyne Model
% 'HDL32E'	HDL-32E sensor
% 'VLP32C'	VLP-32C Ultra Puck sensor
% 'VLP16'	VLP-16 Puck sensor
% 'PuckLITE'	VLP-16 Puck Lite sensor
% 'PuckHiRes'	VLP-16 Puck Hi-Res sensor

%% 点群のプレビュー
preview(lidar)
pause(10)
closePreview(lidar)

%% 点群のストリーミング取得開始
start(lidar)

%% 最新の点群を取得
[pcloud, timestamp] = read(lidar, 'latest');
pcshow(pcloud);

%% 点群のストリーミングを停止
stop(v)

%%
% Copyright 2019 The MathWorks, Inc.
