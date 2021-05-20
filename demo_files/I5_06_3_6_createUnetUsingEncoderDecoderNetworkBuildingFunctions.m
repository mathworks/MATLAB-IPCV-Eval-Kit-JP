%% 関数によるU-Net作成
% エンコーダ部分の構築
depth = 4;
[encoder,outputNames] = pretrainedEncoderNetwork('googlenet',depth);
% 入力画像サイズの定義
inputSize = encoder.Layers(1).InputSize;
%% エンコーダネットワークの出力サイズの決定
% ネットワークに一度画像を流して、サイズを決定する
exampleInput = dlarray(zeros(inputSize),'SSC');
exampleOutput = cell(1,length(outputNames));
[exampleOutput{:}] = forward(encoder,exampleInput,'Outputs',outputNames);
%% デコーダネットワークの出力のチャンネル数を決定
numChannels = cellfun(@(x) size(extractdata(x),3),exampleOutput);
numChannels = fliplr(numChannels(1:end-1));
%% デコーダネットワークの単位ネットワークを定義
decoderBlock = @(block) [
    transposedConv2dLayer(2,numChannels(block),'Stride',2)
    convolution2dLayer(3,numChannels(block),'Padding','same')
    reluLayer
    convolution2dLayer(3,numChannels(block),'Padding','same')
    reluLayer];
%% デコーダネットワークの構築
decoder = blockedNetwork(decoderBlock,depth);
%% U-Netを構築
net = encoderDecoderNetwork([224 224 3],encoder,decoder, ...
   'OutputChannels',3,'SkipConnections','concatenate');
%% 可視化
analyzeNetwork(net)

% Copyright 2021 The MathWorks, Inc.