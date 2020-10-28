%% HOG (Histogram of Oriented Gradient) ������ ��
%  ���ʕ��ފ�FDiscriminant analysis classifier ���g�����A�菑�������̎���
clear;clc;close all;imtool close all

% �g���[�j���O�摜�i101��x10������j�ƃe�X�g�摜�i12��x10������j�ւ̐�΃p�X��ݒ�
pathData = [toolboxdir('vision'), '\visiondata\digits']
trainSet = imageSet([pathData,'\synthetic'  ], 'recursive');
testSet  = imageSet([pathData,'\handwritten'], 'recursive');

%% �S�g���[�j���O�p�摜��̕\��
figure;montage([trainSet.ImageLocation], 'Size', [26 40]);

%% �S�e�X�g�摜�������^�[�W���\�� (12�� x 10������F�e�菑��������F��)
figure;montage([testSet(:).ImageLocation], 'Size', [10,12]);

%% 4x4�̃Z���T�C�Y���g�p (324�����x�N�g��)
cellSize = [4 4];
hogFeatureSize = 324;                   % length(hog_4x4)

%% [KNN���ފ�̍\�z]�Ffitcknn���g�p
% 10��������trainingFeatures ���i�[����z������炩���ߍ쐻
trainingFeatures  = zeros(10*101,hogFeatureSize, 'single');
trainingLabels    = zeros(10*101,1);

% HOG�����ʂ𒊏o
for digit = 0:9   % ����'0'�`'9'
  for i = 1:101         % �e�������Ƃ�101���̃g���[�j���O�p�摜
    img = read(trainSet(digit+1), i);  %�g���[�j���O�摜�̓Ǎ���       trainSet()�́A1����n�܂�̂ŁA+1
    img = imbinarize(img,graythresh(img));   % ��l��
             
    trainingFeatures((digit)*101+i,:) = extractHOGFeatures(img,'CellSize',cellSize);
    trainingLabels((digit)*101+i)     = digit;
  end
end
% ���ފ�̊w�K: 0�̕��U�����邽�߁A'pseudoLinear'��'pseudoQuadratic' ���g�p
discrModelL = fitcdiscr(trainingFeatures, trainingLabels, 'DiscrimType','pseudoLinear')      %�^�����`���ʕ��ފ�
discrModelQ = fitcdiscr(trainingFeatures, trainingLabels, 'DiscrimType','pseudoQuadratic');  %�^���񎟔��ʕ��ފ�

%% [����] �쐬�������ފ�Ŏ菑������(120��)�����ʥ�\���Fpredict()  => ���̃f�[�^�ɑ΂��Ă͂��܂�������
Ir = zeros([16,16,3,120], 'uint8');      % ���ʂ��i�[����z��
for digit = 0:9   % 
  for i = 1:12         % �e�������Ƃ�12���̎菑������
    img = read(testSet(digit+1), i);    % testSet()�́A1����n�܂�̂ŁA+1
    BW = imbinarize(img,graythresh(img));    % 2�l��

    testFeatures = extractHOGFeatures(BW,'CellSize',cellSize);
    predictedNum = predict(discrModelL, testFeatures);           % testFeature ��z��ɂ��āA���Ƃł܂Ƃ߂Ĕ������
    
    if predictedNum == digit    %���������ʂ͐F�A��F���͐ԐF
      Ir(:,:,:,digit*12+i) = insertText(img,[6 4],num2str(predictedNum),'FontSize',9,'TextColor','blue','BoxOpacity',0.4);
    else
      Ir(:,:,:,digit*12+i) = insertText(img,[6 4],num2str(predictedNum),'FontSize',9,'TextColor','red','BoxOpacity',0.4); 
    end 

  end
end
% ���ʂ̕\��
figure;montage(Ir, 'Size', [10,12]);
%% [����] �쐬�������ފ�Ŏ菑������(120��)�����ʥ�\���Fpredict()  => ���̃f�[�^�ɑ΂��Ă͂��܂�������
Ir = zeros([16,16,3,120], 'uint8');      % ���ʂ��i�[����z��
for digit = 0:9   % 
  for i = 1:12         % �e�������Ƃ�12���̎菑������
    img = read(testSet(digit+1), i);    % testSet()�́A1����n�܂�̂ŁA+1
    BW = imbinarize(img,graythresh(img));    % 2�l��

    testFeatures = extractHOGFeatures(BW,'CellSize',cellSize);
    predictedNum = predict(discrModelQ, testFeatures);           % testFeature ��z��ɂ��āA���Ƃł܂Ƃ߂Ĕ������
    
    if predictedNum == digit    %���������ʂ͐F�A��F���͐ԐF
      Ir(:,:,:,digit*12+i) = insertText(img,[6 4],num2str(predictedNum),'FontSize',9,'TextColor','blue','BoxOpacity',0.4);
    else
      Ir(:,:,:,digit*12+i) = insertText(img,[6 4],num2str(predictedNum),'FontSize',9,'TextColor','red','BoxOpacity',0.4); 
    end 

  end
end
% ���ʂ̕\��
figure;montage(Ir, 'Size', [10,12]);

%%








%% Copyright 2013-2014 The MathWorks, Inc.
% �摜�f�[�^�Z�b�g
% �g���[�j���O�摜�FinsertText�֐��Ŏ����쐬 (���͂ɕʂ̐����L��)
% �e�X�g�摜�F�菑���̉摜���g�p
