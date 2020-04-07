%% SSD�ɂ�镨�̌��o��̊w�K
% ���̃f���ł�SSD�ɂ�镨�̌��o���s���܂��B
% ���s�ɂ͉��L��Toolbox���K�v�ɂȂ�܂��B
% Computer Vision Toolbox
% Deep Learning Toolbox
% Parallel Computing Toolbox(NVIDIA GPU�ł̊w�K�E���_�̍������j
%
% Resnet50�̓ǂݍ��݂ɂ͖����̃A�h�I�����C���X�g�[�����K�v�ł��B
% ��[�z�[��]-[�A�h�I��]����C���X�g�[��


%% ������
clear; close all force; clc; rng('default');

%% �ԗ����o��p�̊w�K�f�[�^�Z�b�g�����[�h
unzip vehicleDatasetImages.zip
data = load('vehicleDatasetGroundTruth.mat');
vehicleDataset = data.vehicleDataset;

%% �w�K�p�f�[�^(60%)�ƃe�X�g�p�f�[�^(40%)�ɕ���
rng(0);
shuffledIndices = randperm(height(vehicleDataset));
idx = floor(0.6 * length(shuffledIndices) );
trainingData = vehicleDataset(shuffledIndices(1:idx),:);
testData = vehicleDataset(shuffledIndices(idx+1:end),:);

imdsTrain = imageDatastore(trainingData{:,'imageFilename'});
bldsTrain = boxLabelDatastore(trainingData(:,'vehicle'));

imdsTest = imageDatastore(testData{:,'imageFilename'});
bldsTest = boxLabelDatastore(testData(:,'vehicle'));

trainingData = combine(imdsTrain,bldsTrain);
testData = combine(imdsTest, bldsTest);


%% YOLO v2�l�b�g���[�N���`
% ���͉摜�T�C�Y
inputSize = [300 300 3];

% �N���X��(����͎ԗ��݂̂Ȃ̂�1��)
numClasses = width(vehicleDataset)-1;

% SSD�l�b�g���[�N�̍쐬
lgraph = ssdLayers(inputSize, numClasses, 'resnet50');


%% �f�[�^�̐������ƑO����

% �f�[�^�̐�����(���]�E�ړ�)
augmentedTrainingData = transform(trainingData,@augmentData);
% �O�����i���T�C�Y�j
preprocessedTrainingData = transform(augmentedTrainingData,@(data)preprocessData(data,inputSize));

%% �w�K�I�v�V�������w��
options = trainingOptions('sgdm', ...
        'MiniBatchSize', 16, ....
        'InitialLearnRate',1e-1, ...
        'LearnRateSchedule', 'piecewise', ...
        'LearnRateDropPeriod', 30, ...
        'LearnRateDropFactor', 0.8, ...
        'MaxEpochs', 300, ...
        'VerboseFrequency', 50, ...        .
        'Shuffle','every-epoch');

%% �J�X�^����SSD�l�b�g���[�N�̊w�K
[detector, info] = trainSSDObjectDetector(preprocessedTrainingData,lgraph,options);

% �w�K�ς݃��f���͈ȉ��Ń_�E�����[�h�\
% disp('Downloading pretrained detector (44 MB)...');
% pretrainedURL = 'https://www.mathworks.com/supportfiles/vision/data/ssdResNet50VehicleExample_20a.mat';
% websave('ssdResNet50VehicleExample_20a.mat',pretrainedURL);
% pretrained = load('ssdResNet50VehicleExample_20a.mat');
% detector = pretrained.detector;

%% �e�X�g�摜�̓ǂݍ��݂ƌ��o
data = read(testData);
I = data{1,1};
I = imresize(I,inputSize(1:2));
[bboxes,scores] = detect(detector,I, 'Threshold', 0.4);

I = insertObjectAnnotation(I,'rectangle',bboxes,scores);
figure
imshow(I)


%% �T�|�[�g�֐�

function B = augmentData(A)

B = cell(size(A));

I = A{1};
sz = size(I);

% �����_���ɐF����ω�
if numel(sz)==3 && sz(3) == 3
    I = jitterColorHSV(I,...
        'Contrast',0.2,...
        'Hue',0,...
        'Saturation',0.1,...
        'Brightness',0.2);
end

% �����_���ɔ��]�Ɗg��
tform = randomAffine2d('XReflection',true,'Scale',[1 1.1]);  
rout = affineOutputView(sz,tform,'BoundsStyle','CenterOutput');    
B{1} = imwarp(I,tform,'OutputView',rout);
[B{2},indices] = bboxwarp(A{2},tform,rout,'OverlapThreshold',0.25);    
B{3} = A{3}(indices);
    
% ���E�{�b�N�X�������Ă��܂��ꍇ�͌��̉摜���g�p
if isempty(indices)
    B = A;
end
end

function data = preprocessData(data,targetSize)
% �摜�Ƌ��E�{�b�N�X�̃��T�C�Y
scale = targetSize(1:2)./size(data{1},[1 2]);
data{1} = imresize(data{1},targetSize(1:2));
data{2} = bboxresize(data{2},scale);
end

%% _Copyright 2020 The MathWorks, Inc._
