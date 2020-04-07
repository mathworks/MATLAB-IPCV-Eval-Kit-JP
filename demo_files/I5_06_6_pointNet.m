%% ディープラーニングによる点群の分類：PointNet
% このデモではPointNetによる点群の分類を行います。
% 実行には下記のToolboxが必要になります。
% Computer Vision Toolbox
% Deep Learning Toolbox
% Parallel Computing Toolbox(NVIDIA GPUでの学習・推論の高速化）

% 処理のより詳細な説明は下記の例題をご参照ください。
% https://www.mathworks.com/help/releases/R2020a/vision/examples/point-cloud-classification-using-pointnet-deep-learning.html

% 必要なサポート関数へのパスを追加
addpath(fullfile(matlabroot,'\examples\deeplearning_shared\main'));

%% データのダウンロード
datapath = downloadSydneyUrbanObjects;

%datapath = "C:\Users\kmachida\Desktop\OneDrive_1_2020-3-24\demo\sydney-urban-objects-dataset"

%% 学習用と検証用にデータ分割
foldsTrain = 1:3;
foldsVal = 4;
dsTrain = sydneyUrbanObjectsClassificationDatastore(datapath,foldsTrain);
dsVal = sydneyUrbanObjectsClassificationDatastore(datapath,foldsVal);


%% データの一つを確認
data = read(dsTrain);
ptCloud = data{1,1};
label = data{1,2};

figure
pcshow(ptCloud.Location,[0 0 1],"MarkerSize",40,"VerticalAxisDir","down")
xlabel("X");ylabel("Y");zlabel("Z");
title(label)

%% クラス毎のデータ数の分布を確認
dsLabelCounts = transform(dsTrain,@(data){data{2} data{1}.Count});
labelCounts = readall(dsLabelCounts);
labels = vertcat(labelCounts{:,1});
counts = vertcat(labelCounts{:,2});

figure
histogram(labels)

%% 頻度の少ないクラスのデータを複製
rng(0)
[G,classes] = findgroups(labels);
numObservations = splitapply(@numel,labels,G);
desiredNumObservationsPerClass = max(numObservations);
files = splitapply(@(x){randReplicateFiles(x,desiredNumObservationsPerClass)},dsTrain.Files,G);
files = vertcat(files{:});
dsTrain.Files = files;
dsTrain.Files = dsTrain.Files(randperm(length(dsTrain.Files)));

%% ミニバッチサイズを指定
dsTrain.MiniBatchSize = 128;
dsVal.MiniBatchSize = 128;


%% データの水増し（回転・点群の間引き・ノイズ追加）
dsTrain = transform(dsTrain,@augmentPointCloud);

%% 前処理

% 固定数の点群を抽出
numPoints = 1024; % 1024点の抽出
dsTrain = transform(dsTrain,@(data)selectPoints(data,numPoints));
dsVal = transform(dsVal,@(data)selectPoints(data,numPoints));

% 点群データの正規化
dsTrain = transform(dsTrain,@preprocessPointCloud);
dsVal = transform(dsVal,@preprocessPointCloud);

%% PointNetモデルの定義（モデルの初期化）
% 1.入力変換モデル
inputChannelSize = 3;
hiddenChannelSize1 = [64,128];
hiddenChannelSize2 = 256;
[parameters.InputTransform, state.InputTransform] = initializeTransform(inputChannelSize,hiddenChannelSize1,hiddenChannelSize2);

% 2.Shared MLPモデル
inputChannelSize = 3;
hiddenChannelSize = [64 64];
[parameters.SharedMLP1,state.SharedMLP1] = initializeSharedMLP(inputChannelSize,hiddenChannelSize);

% 3.特徴変換モデル
inputChannelSize = 64;
hiddenChannelSize1 = [64,128];
hiddenChannelSize2 = 256;
[parameters.FeatureTransform, state.FeatureTransform] = initializeTransform(inputChannelSize,hiddenChannelSize,hiddenChannelSize2);

% 4.Shared MLPモデル
inputChannelSize = 64;
hiddenChannelSize = 64;
[parameters.SharedMLP2,state.SharedMLP2] = initializeSharedMLP(inputChannelSize,hiddenChannelSize);

% 分類モデル
inputChannelSize = 64;
hiddenChannelSize = [512,256];
numClasses = numel(classes);
[parameters.ClassificationMLP, state.ClassificationMLP] = initializeClassificationMLP(inputChannelSize,hiddenChannelSize,numClasses);


%% 学習オプションの設定
numEpochs = 40;
learnRate = 0.001;
l2Regularization = 0.01;
learnRateDropPeriod = 15;
learnRateDropFactor = 0.5;

gradientDecayFactor = 0.9;
squaredGradientDecayFactor = 0.999;

%% 学習の実行

avgGradients = [];
avgSquaredGradients = [];

doTraining = true;% true:学習の実行　false:学習後のモデルを使用

if doTraining
    
    % 学習の進捗確認用のプロッター作成
    [lossPlotter, trainAccPlotter,valAccPlotter] = initializeTrainingProgressPlot;
    
    numClasses = numel(classes);
    iteration = 0;
    start = tic;
    for epoch = 1:numEpochs
        
        % データセットのリセット
        reset(dsTrain);
        reset(dsVal);
        
        while hasdata(dsTrain)
            iteration = iteration + 1;
            
            % データの読み込み
            data = read(dsTrain);
            
            % バッチデータの作成
            [XTrain,YTrain] = batchData(data);
            
            % 勾配と損失の計算
            [gradients, loss, state, acc] = dlfeval(@modelGradients,XTrain,YTrain,parameters,state);
            
            % L2正則化
            gradients = dlupdate(@(g,p) g + l2Regularization*p,gradients,parameters);
            
            % ネットワークの重みを更新
            [parameters, avgGradients, avgSquaredGradients] = adamupdate(parameters, gradients, ...
                avgGradients, avgSquaredGradients, iteration,...
                learnRate,gradientDecayFactor, squaredGradientDecayFactor);
            
            % プロッターを更新
            D = duration(0,0,toc(start),"Format","hh:mm:ss");
            title(lossPlotter.Parent,"Epoch: " + epoch + ", Elapsed: " + string(D))
            addpoints(lossPlotter,iteration,double(gather(extractdata(loss))))
            addpoints(trainAccPlotter,iteration,acc);
            drawnow
        end
        
        % 検証用データでモデルを評価
        cmat = sparse(numClasses,numClasses);
        while hasdata(dsVal)
            
            % 次のデータを読み込み
            data = read(dsVal);
            
            % バッチデータの作成.
            [XVal,YVal] = batchData(data);
            
            % クラスの推論
            isTraining = false;
            YPred = pointnetClassifier(XVal,parameters,state,isTraining);
            
            % スコアが一番高かったクラスを抽出.
            [~,YValLabel] = max(YVal,[],1);
            [~,YPredLabel] = max(YPred,[],1);
            
            % 混同行列の集計
            cmat = aggreateConfusionMetric(cmat,YValLabel,YPredLabel);
        end
        
        % 平均の分類精度をプロッターに追加
        acc = sum(diag(cmat))./sum(cmat,"all");
        addpoints(valAccPlotter,iteration,acc);
        
        % 学習率の更新
        if mod(epoch,learnRateDropPeriod) == 0
            learnRate = learnRate * learnRateDropFactor;
        end
        
        % データセットのリセット
        reset(dsTrain);
        reset(dsVal);
    end

else
    % 学習済みモデルのダウンロードと読み込み
    pretrainedURL = 'https://www.mathworks.com/supportfiles/vision/data/pretrainedPointNet.mat';
    
    pretrainedNetwork = fullfile(pwd,'pretrainedPointNet.mat');
    if ~exist(pretrainedNetwork,'file')
        disp('Downloading pretrained network (5 MB)...');
        websave(pretrainedNetwork,pretrainedURL);
    end
    
    pretrainedResults = load('pretrainedPointNet.mat');
    parameters = pretrainedResults.parameters;
    state = pretrainedResults.state;
    cmat = pretrainedResults.cmat;
    
    % GPUがある場合はgpuArrayに変換
    parameters = prepareForPrediction(parameters,@(x)dlarray(toDevice(x,canUseGPU)));
    state = prepareForPrediction(state,@(x)toDevice(x,canUseGPU));

end

% 混同行列の表示
figure
chart = confusionchart(cmat,classes);

acc = sum(diag(cmat))./sum(cmat,"all")


%% 学習したモデルで分類

ptCloud = pcread("car.pcd");
X = preprocessPointCloud(ptCloud);
dlX = dlarray(X{1},"SCSB");

YPred = pointnetClassifier(dlX,parameters,state,false);
[~,classIdx] = max(YPred,[],1);

figure
pcshow(ptCloud.Location,[0 0 1],"MarkerSize",40,"VerticalAxisDir","down")
title(classes(classIdx))




%% 損失の勾配計算
function [gradients, loss, state, acc] = modelGradients(X,Y,parameters,state)

% Execute the model function.
isTraining = true;
[YPred,state,dlT] = pointnetClassifier(X,parameters,state,isTraining);

% Add regularization term to ensure feature transform matrix is
% approximately orthogonal.
K = size(dlT,1);
B = size(dlT, 4);
I = repelem(eye(K),1,1,1,B);
dlI = dlarray(I,"SSCB");
treg = mse(dlI,dlmtimes(dlT,permute(dlT,[2 1 3 4])));
factor = 0.001;

% Compute the loss.
loss = crossentropy(YPred,Y) + factor*treg;

% Compute the parameter gradients with respect to the loss. 
gradients = dlgradient(loss, parameters);

% Compute training accuracy metric.
[~,YTest] = max(Y,[],1);
[~,YPred] = max(YPred,[],1);
acc = gather(extractdata(sum(YTest == YPred)./numel(YTest)));

end

%% PointNetの推論関数（分類）
function [dlY,state,dlT] = pointnetClassifier(dlX,parameters,state,isTraining)

% Invoke the PointNet encoder.
[dlY,state,dlT] = pointnetEncoder(dlX,parameters,state,isTraining);

% Invoke the classifier.
p = parameters.ClassificationMLP.Perceptron;
s = state.ClassificationMLP.Perceptron;
for k = 1:numel(p) 
     
    [dlY, s(k)] = perceptron(dlY,p(k),s(k),isTraining);
      
    % If training, apply inverted dropout with a probability of 0.3.
    if isTraining
        probability = 0.3; 
        dropoutScaleFactor = 1 - probability;
        dropoutMask = ( rand(size(dlY), "like", dlY) > probability ) / dropoutScaleFactor;
        dlY = dlY.*dropoutMask;
    end
    
end
state.ClassificationMLP.Perceptron = s;

% Apply final fully connected and softmax operations.
weights = parameters.ClassificationMLP.FC.Weights;
bias = parameters.ClassificationMLP.FC.Bias;
dlY = fullyconnect(dlY,weights,bias);
dlY = softmax(dlY);
end

%% PointNetのエンコーダ
function [dlY,state,T] = pointnetEncoder(dlX,parameters,state,isTraining)
% Input transform.
[dlY,state.InputTransform] = dataTransform(dlX,parameters.InputTransform,state.InputTransform,isTraining);

% Shared MLP.
[dlY,state.SharedMLP1.Perceptron] = sharedMLP(dlY,parameters.SharedMLP1.Perceptron,state.SharedMLP1.Perceptron,isTraining);

% Feature transform.
[dlY,state.FeatureTransform,T] = dataTransform(dlY,parameters.FeatureTransform,state.FeatureTransform,isTraining);

% Shared MLP.
[dlY,state.SharedMLP2.Perceptron] = sharedMLP(dlY,parameters.SharedMLP2.Perceptron,state.SharedMLP2.Perceptron,isTraining);

% Max operation.
dlY = max(dlY,[],1);
end

%% シェアード多層パーセプトロン
function [dlY,state] = sharedMLP(dlX,parameters,state,isTraining)
dlY = dlX;
for k = 1:numel(parameters) 
    [dlY, state(k)] = perceptron(dlY,parameters(k),state(k),isTraining);
end
end

%% パーセプトロン
function [dlY,state] = perceptron(dlX,parameters,state,isTraining)
% Convolution.
W = parameters.Conv.Weights;
B = parameters.Conv.Bias;
dlY = dlconv(dlX,W,B);

% Batch normalization. Update batch normalization state when training.
offset = parameters.BatchNorm.Offset;
scale = parameters.BatchNorm.Scale;
trainedMean = state.BatchNorm.TrainedMean;
trainedVariance = state.BatchNorm.TrainedVariance;
if isTraining
    [dlY,trainedMean,trainedVariance] = batchnorm(dlY,offset,scale,trainedMean,trainedVariance);
    
    % Update state.
    state.BatchNorm.TrainedMean = trainedMean;
    state.BatchNorm.TrainedVariance = trainedVariance;
else
    dlY = batchnorm(dlY,offset,scale,trainedMean,trainedVariance);
end

% ReLU.
dlY = relu(dlY);
end

%% データ変換関数
function [dlY,state,T] = dataTransform(dlX,parameters,state,isTraining)

% Shared MLP.
[dlY,state.Block1.Perceptron] = sharedMLP(dlX,parameters.Block1.Perceptron,state.Block1.Perceptron,isTraining);

% Max operation.
dlY = max(dlY,[],1);

% Shared MLP.
[dlY,state.Block2.Perceptron] = sharedMLP(dlY,parameters.Block2.Perceptron,state.Block2.Perceptron,isTraining);

% Transform net (T-Net). Apply last fully connected operation as W*X to
% predict tranformation matrix T.
dlY = extractdata(dlY);
dlY = squeeze(dlY); % N-by-B
T = parameters.Transform * dlY; % K^2-by-B

% Reshape T into a square matrix.
K = sqrt(size(T,1));
T = reshape(T,K,K,1,[]); % [K K 1 B]
T = T + eye(K);

% Apply to input dlX using batch matrix multiply. 
X = extractdata(dlX); % [M 1 K B]
[C,B] = size(X,[3 4]);
X = reshape(X,[],C,1,B); % [M K 1 B]
Y = dlmtimes(X,T);
dlY = dlarray(Y,"SCSB");
end

%% モベルパラメータ初期化関数

function [params,state] = initializeTransform(inputChannelSize,block1,block2)
[params.Block1,state.Block1] = initializeSharedMLP(inputChannelSize,block1);
[params.Block2,state.Block2] = initializeSharedMLP(block1(end),block2);

% Parameters for the transform matrix.
params.Transform = dlarray(zeros(inputChannelSize^2,block2(end)));
end

function [params,state] = initializeSharedMLP(inputChannelSize,hiddenChannelSize)
weights = initializeWeightsHe([1 1 inputChannelSize hiddenChannelSize(1)]);
bias = zeros(hiddenChannelSize(1),1,"single");
p.Conv.Weights = dlarray(weights);
p.Conv.Bias = dlarray(bias);

p.BatchNorm.Offset = dlarray(zeros(hiddenChannelSize(1),1,"single"));
p.BatchNorm.Scale = dlarray(ones(hiddenChannelSize(1),1,"single"));

s.BatchNorm.TrainedMean = zeros(hiddenChannelSize(1),1,"single");
s.BatchNorm.TrainedVariance = ones(hiddenChannelSize(1),1,"single");

params.Perceptron(1) = p;
state.Perceptron(1) = s;

for k = 2:numel(hiddenChannelSize)
    weights = initializeWeightsHe([1 1 hiddenChannelSize(k-1) hiddenChannelSize(k)]);
    bias = zeros(hiddenChannelSize(k),1,"single");
    p.Conv.Weights = dlarray(weights);
    p.Conv.Bias = dlarray(bias);
    
    p.BatchNorm.Offset = dlarray(zeros(hiddenChannelSize(k),1,"single"));
    p.BatchNorm.Scale = dlarray(ones(hiddenChannelSize(k),1,"single"));
    
    s.BatchNorm.TrainedMean = zeros(hiddenChannelSize(k),1,"single");
    s.BatchNorm.TrainedVariance = ones(hiddenChannelSize(k),1,"single");

    params.Perceptron(k) = p;
    state.Perceptron(k) = s;
end
end



function [params,state] = initializeClassificationMLP(inputChannelSize,hiddenChannelSize,numClasses)
[params,state] = initializeSharedMLP(inputChannelSize,hiddenChannelSize);

weights = initializeWeightsGaussian([numClasses hiddenChannelSize(end)]);
bias = zeros(numClasses,1,"single");
params.FC.Weights = dlarray(weights);
params.FC.Bias = dlarray(bias);
end


function x = initializeWeightsHe(sz)
fanIn = prod(sz(1:3));
stddev = sqrt(2/fanIn);
x = stddev .* randn(sz);
end

function x = initializeWeightsGaussian(sz)
x = randn(sz,"single") .* 0.01;
end

function data = preprocessPointCloud(data)

if ~iscell(data)
    data = {data};
end

numObservations = size(data,1);
for i = 1:numObservations
    % Scale points between 0 and 1.
    xlim = data{i,1}.XLimits;
    ylim = data{i,1}.YLimits;
    zlim = data{i,1}.ZLimits;
    
    xyzMin = [xlim(1) ylim(1) zlim(1)];
    xyzDiff = [diff(xlim) diff(ylim) diff(zlim)];
    
    data{i,1} = (data{i,1}.Location - xyzMin) ./ xyzDiff;
end
end

function data = selectPoints(data,numPoints) 
% Select the desired number of points by downsampling or replicating
% point cloud data.
numObservations = size(data,1);
for i = 1:numObservations    
    ptCloud = data{i,1};
    if ptCloud.Count > numPoints
        percentage = numPoints/ptCloud.Count;
        data{i,1} = pcdownsample(ptCloud,"random",percentage);   
    else    
        replicationFactor = ceil(numPoints/ptCloud.Count);
        ind = repmat(1:ptCloud.Count,1,replicationFactor);
        data{i,1} = select(ptCloud,ind(1:numPoints));
    end 
end
end

function data = augmentPointCloud(data)
   
numObservations = size(data,1);
for i = 1:numObservations
    
    ptCloud = data{i,1};
    
    % Rotate the point cloud about "up axis", which is Z for this data set.
    tform = randomAffine3d(...
        "XReflection", true,...
        "YReflection", true,...
        "Rotation",@randomRotationAboutZ);
    
    ptCloud = pctransform(ptCloud,tform);
    
    % Randomly drop out 30% of the points.
    if rand > 0.5
        ptCloud = pcdownsample(ptCloud,'random',0.3);
    end
    
    if rand > 0.5
        % Jitter the point locations with Gaussian noise with a mean of 0 and 
        % a standard deviation of 0.02 by creating a random displacement field.
        D = 0.02 * randn(size(ptCloud.Location));
        ptCloud = pctransform(ptCloud,D);   
    end
    
    data{i,1} = ptCloud;
end
end

function [rotationAxis,theta] = randomRotationAboutZ()
rotationAxis = [0 0 1];
theta = 2*pi*rand;
end


%% サポート関数

function cmat = aggreateConfusionMetric(cmat,YTest,YPred)
YTest = gather(extractdata(YTest));
YPred = gather(extractdata(YPred));
[m,n] = size(cmat);
cmat = cmat + full(sparse(YTest,YPred,1,m,n));
end



function [plotter,trainAccPlotter,valAccPlotter] = initializeTrainingProgressPlot()
% Plot the loss, training accuracy, and validation accuracy.
figure

% Loss plot
subplot(2,1,1)
plotter = animatedline;
xlabel("Iteration")
ylabel("Loss")

% Accuracy plot
subplot(2,1,2)
trainAccPlotter = animatedline('Color','b');
valAccPlotter = animatedline('Color','g');
legend('Training Accuracy','Validation Accuracy','Location','northwest');
xlabel("Iteration")
ylabel("Accuracy")
end




function files = randReplicateFiles(files,numDesired)
n = numel(files);
ind = randi(n,numDesired,1);
files = files(ind);
end

function datapath = downloadSydneyUrbanObjects(dataLoc)

if nargin == 0
    dataLoc = pwd;
end

dataLoc = string(dataLoc);

url = "http://www.acfr.usyd.edu.au/papers/data/";
name = "sydney-urban-objects-dataset.tar.gz";

datapath = fullfile(dataLoc,'sydney-urban-objects-dataset');
if ~exist(datapath,'dir')
    disp('Downloading Sydney Urban Objects data set...');
    untar([url+name],dataLoc);
end

end



function [dlX,dlY] = batchData(data)
X = cat(4,data{:,1});
labels = cat(1,data{:,2});
Y = oneHotEncode(labels);

% Cast data to single for processing.
X = single(X);
Y = single(Y);

% Move data to the GPU if possible.
if canUseGPU
    X = gpuArray(X);
    Y = gpuArray(Y);
end

% Return X and Y as dlarray objects.
dlX = dlarray(X,'SCSB');
dlY = dlarray(Y,'CB');
end





function Y = oneHotEncode(labels)
numObservations = numel(labels);
numCategories = numel(categories(labels));
sz = [numCategories, numObservations];
Y = zeros(sz, 'single');
labels = labels';
idx = sub2ind(sz, int32(labels), 1:numObservations);
Y(idx) = 1;
end




function p = prepareForPrediction(p,fcn)

for i = 1:numel(p)
    p(i) = structfun(@(x)invoke(fcn,x),p(i),'UniformOutput',0);
end

    function data = invoke(fcn,data)
        if isstruct(data)
            data = prepareForPrediction(data,fcn);
        else
            data = fcn(data);
        end
    end
end

% Move data to the GPU.
function x = toDevice(x,useGPU)
if useGPU
    x = gpuArray(x);
end
end

%% _Copyright 2020 The MathWorks, Inc._