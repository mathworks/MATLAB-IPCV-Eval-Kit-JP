%% Pre-Trained モデルの読込み
net = alexnet
net = vgg16
net = vgg19
net = squeezenet
net = googlenet
net = inceptionv3
net = densenet201
net = mobilenetv2
net = resnet18
net = resnet50
net = resnet101
net = xception
net = inceptionresnetv2

%% GoogleNetを使用
net = googlenet

%% ネットワークの層構造の表示
net.Layers

%% ネットワークの層構造の表示(グラフ)
plot(net)

%% 分類する画像の読込み
I = imread('peppers.png');

%% ネットワークの入力サイズへ画像を切出し･表示
sz = net.Layers(1).InputSize 
I = I(1:sz(1),1:sz(2),1:sz(3));
figure; imshow(I);

%% 分類(推論)
label = classify(net, I)

%% 結果の可視化
I1 = insertText(I, [20 20], char(label));
imshow(I1); shg;

%%
% Copyright 2018 The MathWorks, Inc.