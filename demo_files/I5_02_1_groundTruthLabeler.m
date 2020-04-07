%% 5.2.1 機械学習：ビデオおよび点群のラベリングアプリケーション

%% タイムスタンプデータの読み込み
pcSeqFolder = fullfile(toolboxdir('driving'),'drivingdata','lidarSequence');
addpath(pcSeqFolder)
load timestamps.mat
rmpath(pcSeqFolder)

%% 点群ファイルをコピー
newDir = 'I5_02_1_lidarSeq';
[~,~,~] = mkdir(newDir);
pcdDs = fileDatastore(pcSeqFolder,'ReadFcn',@(filename)pcread);
filelist = pcdDs.Files;
% 新しい名前を付与してコピー
for i = 1:size(filelist,1)
    filename = filelist{i};
    [filepath,name,ext] = fileparts(filename);
    if strcmp(ext, '.pcd')
        newStrs = strsplit(filename, '_');
        num = str2double(extractBefore(newStrs{end}, '.pcd'));
        newFname = fullfile(pwd, newDir, ['ptcloud_', sprintf('%03d', num), '.pcd']);  
        copyfile(filename, newFname)
    end
end
 
%% 動画を引数にしてグランドトゥルスラベラーを起動
groundTruthLabeler(fullfile(matlabroot,'toolbox/driving/drivingdata/01_city_c2s_fcw_10s.mp4'));

%% 点群データを読み込み
% 「ソースタイプ」をPoint Cloud Sequenceにし、
%「File Name」に下記の実行結果のパスを入力
% 「Timestamps」はFrom Workspaceにしtimestampsを指定
% 「ソースの追加」をクリックで追加
fullfile(newDir)

%% 下記に沿ってラベリング
web(fullfile(docroot, 'driving/ug/label-ground-truth-for-multiple-signals.html'))

%%
% Copyright 2020 The MathWorks, Inc.
