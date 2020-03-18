%% 多層ニューラルネットワーク：Deep Neural Network(NN)の学習による数字識別
%  Autoencoderの手法で学習したEncoderを多段重ねた識別器： Stacked Autoencoder
%  GPUや並列処理のオプションを使うには、Parallel Computing Toolbox のライセンスが必要
clc;clear;close all;imtool close all;rng('default')

%% 学習用画像の読込み  （数字をランダムなアフィン変換で変形したものを使用）
%     xTrainImages：学習用画像：28x28ピクセルの画像が5003枚    (セル配列)
%     tTrain      ：ラベル（教師データ）10x5003
[xTrainImages, tTrain] = digitTrainCellArrayData;

%% 学習用画像の一部(80枚)を表示
figure; montage(reshape([xTrainImages{1:80}], [28 28 1 80]), 'Size', [8,10]);

%% ラベル(教師データ)の確認
openvar('tTrain')     % 10行目は、文字0に対応

%% [第一隠れ層]: Autoencoderによる1回目の学習 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AutoencoderによるNNの学習：出力値が入力値と同じになるように、教師なし学習
%                            隠れ層のサイズが入力より少なくなることで、入力情報を圧縮
% Autoencoderクラスを使用
% GPUによる高速化も可能
hiddenSize1 = 100;    % Encoderの数(ニューロンの数)
autoenc1 = trainAutoencoder(xTrainImages, hiddenSize1, ...
                                'MaxEpochs',400, ...      % 学習回数（世代）
                                'L2WeightRegularization',0.004, ...        % impact of an L2 regularizer for the weights of the network (and not the biases). This should typically be quite small.
                                'SparsityRegularization',4, ...            % impact of a sparsity regularizer, which attempts to enforce a constraint on the sparsity of the output from the hidden layer
                                'SparsityProportion',0.15, ...
                                'ScaleData', false);
%% ウェイトの可視化：Encoderが学習した特徴
%    サイズ：入力28x28=784ピクセル(ノード)、第一層(隠れ/中間層)100、第一層の出力100、 出力28x28=784ピクセル、隠れ(中間)層100
%    ノード毎に、784次のウェイトwと定数バイアスbがある。
%      (100個のニューロンがそれぞれ活性化する入力パターン：それぞれ曲りや直線パターンを表現)
b1 = autoenc1.EncoderBiases             % 第一層のバイアス
w1 = autoenc1.EncoderWeights;           % 第一層のウェイト
figure; plotWeights(autoenc1);          % ウェイトの可視化


%% [第二隠れ層]：1回目の学習で作ったEncoderの出力を用い、2つ目のAutoencoder学習 %%%%%%%%%
% 一段目のEncoderの、学習画像に対する出力(特徴)を計算 => 学習2の学習用画像
feat1 = encode(autoenc1, xTrainImages);
%% 隠れ層のサイズ50で学習
hiddenSize2 = 50;
autoenc2 = trainAutoencoder(feat1, hiddenSize2, ...
                              'MaxEpochs',100, ...
                              'L2WeightRegularization',0.002, ...
                              'SparsityRegularization',4, ...
                              'SparsityProportion',0.1, ...
                              'ScaleData', false);

%% [最終層]： 二段目の出力50個から、10クラスへ識別する最終段のSoftmax層を学習 %%%%%%%%
% 二段目のEncoderの出力を計算
%   入力は、学習時に用いた、"学習画像(784x5000個)に対する一段目のEncoder出力"を使用(100x5000個)
feat2 = encode(autoenc2, feat1);     % 結果は 50x5000
%% 最終層の学習：5000個の50次学習データに対応する教師データ(tTrain)を使用
softnet = trainSoftmaxLayer(feat2, tTrain, 'MaxEpochs',400);

%% [結合]：学習した3つの層を結合･表示
deepnet = stack(autoenc1, autoenc2, softnet)           % network object
view(deepnet);

%% [テスト用画像を分類]
% テスト画像~5000枚の読込み： テスト画像:xTestImages、ラベル:tTest(10x4997)
[xTestImages, tTest] = digitTestCellArrayData;
% セル形式の~5000個のテスト用画像を、各列が一つの画像データ(28x28=784)の行列に変換
xTestMatrix = reshape([xTestImages{:}], [28*28 4997]);   % 784行4997列の行列

%% 分類
result1 = deepnet(xTestMatrix);        % 10x4997

%% ~5000画像の認識結果のうち、最初の100個を分類･結果を表示(赤が誤認識)
Ir = zeros([28,28,3,100]);      % 結果を格納する配列
for k = 1:100
  img = xTestImages{k};
  [~, maxI] = max(result1(:,k));
  if maxI == find(tTest(:,k))
      colorN = 'green';
  else
      colorN = 'red';
  end
  img = insertText(img, [0 0], mod(maxI,10), 'TextColor',colorN, 'FontSize',14, 'BoxOpacity',0, 'Font','Lucida Sans Typewriter Bold');
  Ir(:,:,:,k)=img;
end
figure;montage(Ir);

%% 混合行列の表示
figure;plotconfusion(tTest, result1);

%% [微調整] 誤差逆伝搬法によりウェイトの微調整し、テスト用画像を再分類
% セル形式の~5000個の学習用画像を、各列が一つの画像データ(28x28=784)の行列に変換
xTrain = reshape([xTrainImages{:}], [28*28 5003]);   % 784行5003列の行列
% 微調整
deepnet = train(deepnet, xTrain, tTrain);

%% 再分類
result2 = deepnet(xTestMatrix);        % 10x4997
Ir = zeros([28,28,3,100]);      % 結果を格納する配列
for k = 1:100
  img = xTestImages{k};
  [~, maxI] = max(result2(:,k));
  if maxI == find(tTest(:,k))
      colorN = 'green';
  else
      colorN = 'red';
  end
  img = insertText(img, [0 0], mod(maxI,10), 'TextColor',colorN, 'FontSize',14, 'BoxOpacity',0, 'Font','Lucida Sans Typewriter Bold');
  Ir(:,:,:,k)=img;
end
figure;montage(Ir);

%% 混合行列の表示
figure;plotconfusion(tTest, result2);

%% Copyright 2015 The MathWorks, Inc.

