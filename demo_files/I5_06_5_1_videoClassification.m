%% 5.6.5.1 ディープラーニング：動画の分類

%% 学習済みモデルの読み込み
netCNN = googlenet;

%% データの読み込み
% <http://serre-lab.clps.brown.edu/resource/hmdb-a-large-human-motion-database/ 
% HMDB: a large human motion database>からRARをダウンロードし解凍(|hmdb51_org)。
% 51クラスの7000個のビデオシーケンス。"飲む"、"走る","手を振る"など。|
% 
% ファイル名とラベルを取得するためのサポート関数を使う
dataFolder = "hmdb51_org";
if ~exist(fullfile(pwd,dataFolder),'dir')
    error("データセットhmdb51_orgをダウンロードして解凍してください" +...
    "http://serre-lab.clps.brown.edu/resource/hmdb-a-large-human-motion-database/");
end
[files,labels] = hmdb51Files(dataFolder);

%% ビデオデータを読み込む
% HxWxCx_Sの配列、高さ、幅、チャネル数、フレーム数の順番
idx = 1;
filename = files(idx);
video = readVideo(filename);
size(video)

%% 対応するラベルを確認

labels(idx)

%% imshowで表示
% double型の場合は値が[0 1]の範囲にある必要があるので255で正規化。

numFrames = size(video,4);
figure
for i = 1:numFrames
    frame = video(:,:,:,i);
    imshow(frame/255);
    drawnow
end

%% ビデオから特徴ベクトルの抽出
% 実行には30分以上かかるので注意。

inputSize = netCNN.Layers(1).InputSize(1:2);
layerName = "pool5-7x7_s1";

tempFile = fullfile(tempdir,"hmdb51_org.mat");

if exist(tempFile,'file')
    load(tempFile,"sequences")
else
    numFiles = numel(files);
    sequences = cell(numFiles,1);
    
    for i = 1:numFiles
        fprintf("Reading file %d of %d...\n", i, numFiles)
        
        video = readVideo(files(i));
        video = centerCrop(video,inputSize);
        
        sequences{i,1} = activations(netCNN,video,layerName,'OutputAs','columns');
    end
    
    save(tempFile,"sequences","-v7.3");
end
%% 特徴ベクトルのサイズを確認
% DxSの配列になっている。Dは特徴ベクトルのサイズ。Sはビデオのフレーム数。
sequences(1:10)

%% 学習データの準備
% 学習用と検定用にデータセットを9:1に分割

numObservations = numel(sequences);
idx = randperm(numObservations);
N = floor(0.9 * numObservations);

idxTrain = idx(1:N);
sequencesTrain = sequences(idxTrain);
labelsTrain = labels(idxTrain);

idxValidation = idx(N+1:end);
sequencesValidation = sequences(idxValidation);
labelsValidation = labels(idxValidation);

%% 長めのビデオは除去する
% パディングによる悪影響を避けるために長すぎるシーケンスは除去する。

numObservationsTrain = numel(sequencesTrain);
sequenceLengths = zeros(1,numObservationsTrain);

for i = 1:numObservationsTrain
    sequence = sequencesTrain{i};
    sequenceLengths(i) = size(sequence,2);
end

figure
histogram(sequenceLengths)
title("Sequence Lengths")
xlabel("Sequence Length")
ylabel("Frequency")

%% 400フレーム以上のものは少数派なので除去する。

maxLength = 400;
idx = sequenceLengths > maxLength;
sequencesTrain(idx) = [];
labelsTrain(idx) = [];

%% LSTMネットワークの作成
% BiLSTMレイヤーは2000の隠れ層を設定。
% 出力は1個のラベルなので'OutputMode'を'last'設定。
% fully connected layerは分類数に設定。

numFeatures = size(sequencesTrain{1},1);
numClasses = numel(categories(labelsTrain));

layers = [
    sequenceInputLayer(numFeatures,'Name','sequence')
    bilstmLayer(2000,'OutputMode','last','Name','bilstm')
    dropoutLayer(0.5,'Name','drop')
    fullyConnectedLayer(numClasses,'Name','fc')
    softmaxLayer('Name','softmax')
    classificationLayer('Name','classification')];

%% トレーニングオプションの設定
% ミニバッチごとに最小のフレーム数と同じになるように切り取り。
% エポックごとにデータをシャッフル。

miniBatchSize = 16;
numObservations = numel(sequencesTrain);
numIterationsPerEpoch = floor(numObservations / miniBatchSize);

options = trainingOptions('adam', ...
    'MiniBatchSize',miniBatchSize, ...
    'InitialLearnRate',1e-4, ...
    'GradientThreshold',2, ...
    'Shuffle','every-epoch', ...
    'ValidationData',{sequencesValidation,labelsValidation}, ...
    'ValidationFrequency',numIterationsPerEpoch, ...
    'Plots','training-progress', ...
    'Verbose',false);

%% LSTMネットワークの学習
[netLSTM,info] = trainNetwork(sequencesTrain,labelsTrain,layers,options);

%% 分類精度の確認。

YPred = classify(netLSTM,sequencesValidation,'MiniBatchSize',miniBatchSize);
YValidation = labelsValidation;
accuracy = mean(YPred == YValidation)

%% ビデオ分類ネットワークの組み立て

% 畳み込みレイヤーの追加
cnnLayers = layerGraph(netCNN);

% アクティベーションの層より後の層は削除。
layerNames = ["data" "pool5-drop_7x7_s1" "loss3-classifier" "prob" "output"];
cnnLayers = removeLayers(cnnLayers,layerNames);

% シーケンスインプットレイヤーを先頭に追加
% イメージシーケンスを扱うためにシーケンスインプットレイヤーを定義。
% 'Normalization'オプションを'zerocenter'にし、
% 'Mean'オプションをGoogLeNetのaverageImageに設定。

inputSize = netCNN.Layers(1).InputSize(1:2);
averageImage = netCNN.Layers(1).AverageImage;

inputLayer = sequenceInputLayer([inputSize 3], ...
    'Normalization','zerocenter', ...
    'Mean',averageImage, ...
    'Name','input');

%% 畳み込みを画像のシーケンスそれぞれにかけるためにsequence folding layerを使用する。

layers = [
    inputLayer
    sequenceFoldingLayer('Name','fold')];

lgraph = addLayers(cnnLayers,layers);
lgraph = connectLayers(lgraph,"fold/out","conv1-7x7_s2");

% LSTMレイヤーを追加
% LSTMネットワークからsequence input layerを除去。
lstmLayers = netLSTM.Layers;
lstmLayers(1) = [];

% sequence folding layer、flatten layer、LSTM layersを追加。
layers = [
    sequenceUnfoldingLayer('Name','unfold')
    flattenLayer('Name','flatten')
    lstmLayers];
lgraph = addLayers(lgraph,layers);

% 畳み込み層の最終層("pool5-7x7_s1")をsequence unfolding layer ("unfold/in")に接続。
lgraph = connectLayers(lgraph,"pool5-7x7_s1","unfold/in");

% unfolding layerからシーケンス構造を復元するために、
% sequence folding layerの|"miniBatchSize"出力を|sequence 
% unfolding layerに接続。
lgraph = connectLayers(lgraph,"fold/miniBatchSize","unfold/miniBatchSize");

%% analyzeNetwork関数を使ってネットワークの整合を確認。
analyzeNetwork(lgraph)

%% assembleNetwork関数を使ってネットワークを組み上げ
net = assembleNetwork(lgraph)

%% 新しいビデオに対して分類をかける
% "pushup.mp4"ビデオを読み込んで中央切り出し。
filename = "pushup.mp4";
video = readVideo(filename);

%% 可視化
numFrames = size(video,4);
figure
for i = 1:numFrames
    frame = video(:,:,:,i);
    imshow(frame/255);
    drawnow
end

%% 分類を実行

% classify関数には入力ビデオ列をセル配列として与える必要がある。|
video = centerCrop(video,inputSize);
YPred = classify(net,{video})

%% サポート関数
% ビデオデータを読み出し。

function video = readVideo(filename)

vr = VideoReader(filename);
H = vr.Height;
W = vr.Width;
C = 3;

% Preallocate video array
numFrames = floor(vr.Duration * vr.FrameRate);
video = zeros(H,W,C,numFrames);

% Read frames
i = 0;
while hasFrame(vr)
    i = i + 1;
    video(:,:,:,i) = readFrame(vr);
end

% Remove unallocated frames
if size(video,4) > i
    video(:,:,:,i+1:end) = [];
end

end
%% 
% 中央切り出しと入力画像サイズに合わせてリサイズ。

function videoResized = centerCrop(video,inputSize)

sz = size(video);

if sz(1) < sz(2)
    % Video is landscape
    idx = floor((sz(2) - sz(1))/2);
    video(:,1:(idx-1),:,:) = [];
    video(:,(sz(1)+1):end,:,:) = [];
    
elseif sz(2) < sz(1)
    % Video is portrait
    idx = floor((sz(1) - sz(2))/2);
    video(1:(idx-1),:,:,:) = [];
    video((sz(2)+1):end,:,:,:) = [];
end

videoResized = imresize(video,inputSize(1:2));

end
%% 
% _Copyright 2019 The MathWorks, Inc._