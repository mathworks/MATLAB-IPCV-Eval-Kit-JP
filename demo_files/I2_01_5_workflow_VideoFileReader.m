clear; clc; close all; imtool close all

%% 動画　画像処理・解析のワークフロー %%%%%%%%%%%%%%
% 動画の読込み・表示・書出し 用のシステムオブジェクトの生成
%       VGA (480x640 pixels)
vidReader = vision.VideoFileReader('tilted_face.avi', 'VideoOutputDataType','uint8'); 
%info(vidReader)        %VideoFormat: 'RGB '
    % カメラから直接取込む場合の例
    % vidReader = imaq.VideoDevice('winvideo', 2, 'MJPG_640x480', 'ReturnedDataType','uint8');
    % 注）USBカメラは暗い場面では速度（フレームレート）が低下するものも
vidPlayer = vision.DeployableVideoPlayer;
vidWriter = vision.VideoFileWriter('tmp_myFile.avi');


%% 1フレームずつ順に処理
while ~isDone(vidReader)
   I = step(vidReader);       % 1フレーム 読込み
   %
   % ここに各種画像処理･解析 のコードを挿入 －－－－－－－－－
   %
   step(vidPlayer, I);        % 1フレーム 表示
   %step(vidWriter, I);        % 1フレーム 書出し

end
%% 生成したシステムオブジェクトをリリース
release(vidReader);
release(vidPlayer);
release(vidWriter);

%% 終了


% Copyright 2014 The MathWorks, Inc.


