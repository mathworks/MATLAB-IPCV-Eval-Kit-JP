%% 画像入力のDDPGエージェントによる振り子の振り上げ
% この例ではMATLABでモデル化された振り子をDeep Deterministic Policy Gradient
% (DDPG)エージェントを使ってどのように学習させるかを紹介します。
% 実行にはReinforcement Learning ToolboxとDeep Learning Toolboxが必要です。

%% 環境とのインターフェースを作成
% 振子のための事前定義された環境を作成
env = rlPredefinedEnv('SimplePendulumWithImage-Continuous')

%% 観測と行動の仕様を環境インターフェースから取得。
obsInfo = getObservationInfo(env);
actInfo = getActionInfo(env);

%% 再現性のために乱数のシードを固定する。
rng(0)

%% DDPGエージェントの定義
hiddenLayerSize1 = 400;
hiddenLayerSize2 = 300;

imgPath = [
    imageInputLayer(obsInfo(1).Dimension,'Normalization','none','Name',obsInfo(1).Name)
    convolution2dLayer(10,2,'Name','conv1','Stride',5,'Padding',0)
    reluLayer('Name','relu1')
    fullyConnectedLayer(2,'Name','fc1')
    concatenationLayer(3,2,'Name','cat1')
    fullyConnectedLayer(hiddenLayerSize1,'Name','fc2')
    reluLayer('Name','relu2')
    fullyConnectedLayer(hiddenLayerSize2,'Name','fc3')
    additionLayer(2,'Name','add')
    reluLayer('Name','relu3')
    fullyConnectedLayer(1,'Name','fc4')
    ];
dthetaPath = [
    imageInputLayer(obsInfo(2).Dimension,'Normalization','none','Name',obsInfo(2).Name)
    fullyConnectedLayer(1,'Name','fc5','BiasLearnRateFactor',0,'Bias',0)
    ];
actPath =[
    imageInputLayer(actInfo(1).Dimension,'Normalization','none','Name','action')
    fullyConnectedLayer(hiddenLayerSize2,'Name','fc6','BiasLearnRateFactor',0,'Bias',zeros(hiddenLayerSize2,1))
    ];

criticNetwork = layerGraph(imgPath);
criticNetwork = addLayers(criticNetwork,dthetaPath);
criticNetwork = addLayers(criticNetwork,actPath);
criticNetwork = connectLayers(criticNetwork,'fc5','cat1/in2');
criticNetwork = connectLayers(criticNetwork,'fc6','add/in2');

%% Criticネットワークの構成を可視化します。
figure
plot(criticNetwork)

%% criticのオプション
criticOptions = rlRepresentationOptions('LearnRate',1e-03,'GradientThreshold',1);
% GPUを使ってCNNを学習する場合は下記をコメントを外してしてください。
% criticOptions.UseDevice = 'gpu';

%% Critic表現を作成
critic = rlRepresentation(criticNetwork,criticOptions,'Observation',{'pendImage','angularRate'},obsInfo,'Action',{'action'},actInfo);

%% Actorのためのネットワークを定義
imgPath = [
    imageInputLayer(obsInfo(1).Dimension,'Normalization','none','Name',obsInfo(1).Name)
    convolution2dLayer(10,2,'Name','conv1','Stride',5,'Padding',0)
    reluLayer('Name','relu1')
    fullyConnectedLayer(2,'Name','fc1')
    concatenationLayer(3,2,'Name','cat1')
    fullyConnectedLayer(hiddenLayerSize1,'Name','fc2')
    reluLayer('Name','relu2')
    fullyConnectedLayer(hiddenLayerSize2,'Name','fc3')
    reluLayer('Name','relu3')
    fullyConnectedLayer(1,'Name','fc4')
    tanhLayer('Name','tanh1')
    scalingLayer('Name','scale1','Scale',max(actInfo.UpperLimit))
    ];
dthetaPath = [
    imageInputLayer(obsInfo(2).Dimension,'Normalization','none','Name',obsInfo(2).Name)
    fullyConnectedLayer(1,'Name','fc5','BiasLearnRateFactor',0,'Bias',0)
    ];

actorNetwork = layerGraph(imgPath);
actorNetwork = addLayers(actorNetwork,dthetaPath);
actorNetwork = connectLayers(actorNetwork,'fc5','cat1/in2');

actorOptions = rlRepresentationOptions('LearnRate',1e-04,'GradientThreshold',1);
% GPUを使う場合は下記のコメントを外してください。
% criticOptions.UseDevice = 'gpu';

%% Actor表現を作成
actor = rlRepresentation(actorNetwork,actorOptions,'Observation',{'pendImage','angularRate'},obsInfo,'Action',{'scale1'},actInfo);

%% Actorネットワークの構成を可視化
figure
plot(actorNetwork)

%% DDPGエージェントを作成
agentOptions = rlDDPGAgentOptions(...
    'SampleTime',env.Ts,...
    'TargetSmoothFactor',1e-3,...
    'ExperienceBufferLength',1e6,...
    'DiscountFactor',0.99,...
    'MiniBatchSize',128);
agentOptions.NoiseOptions.Variance = 0.6;
agentOptions.NoiseOptions.VarianceDecayRate = 1e-6;
agent = rlDDPGAgent(actor,critic,agentOptions);

%% エージェントの学習オプション設定
maxepisodes = 5000;
maxsteps = 400;
trainingOptions = rlTrainingOptions(...
    'MaxEpisodes',maxepisodes,...
    'MaxStepsPerEpisode',maxsteps,...
    'Plots','training-progress',...
    'StopTrainingCriteria','AverageReward',...
    'StopTrainingValue',-740);

%% 振り子の状態を可視化
plot(env);

%% 学習を実行
doTraining = false;
if doTraining    
    % Train the agent.
    trainingStats = train(agent,env,trainingOptions);
else
    % Load pretrained agent for the example.
    load(fullfile(matlabroot,'examples','rl','SimplePendulumWithImageDDPG.mat'),...
        'agent'); 
end
%% 学習済みDDPGエージェントの実行
simOptions = rlSimulationOptions('MaxSteps',500);
experience = sim(env,agent,simOptions);

%% 
% _Copyright 2019 The MathWorks, Inc._