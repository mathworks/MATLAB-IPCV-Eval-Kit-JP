%% HOG (Histogram of Oriented Gradient) ������ ��
%  �}���`�N���X SVM ���g�����A�菑�������̎���
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

%% [���ފ�̍\�z]�Ffitcecoc���g�p
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
% ���N���X���ފ�̊w�K�iECOC���������� ���N���X���f���j
svmModel = fitcecoc(trainingFeatures, trainingLabels)

%% [����] �쐬�������ފ�Ŏ菑������(120��)�����ʥ�\���Fpredict()
Ir = zeros([16,16,3,120], 'uint8');      % ���ʂ��i�[����z��
cntTrue = 0;
for digit = 0:9   % 
  for i = 1:12         % �e�������Ƃ�12���̎菑������
    img = read(testSet(digit+1), i);    % testSet()�́A1����n�܂�̂ŁA+1
    BW = imbinarize(img,graythresh(img));    % 2�l��

    testFeatures = extractHOGFeatures(BW,'CellSize',cellSize);
    predictedNum = predict(svmModel, testFeatures);           % testFeature ��z��ɂ��āA���Ƃł܂Ƃ߂Ĕ������
    
    if predictedNum == digit    %���������ʂ͐F�A��F���͐ԐF
      Ir(:,:,:,digit*12+i) = insertText(img,[6 4],num2str(predictedNum),'FontSize',9,'TextColor','blue','BoxOpacity',0.4);
      cntTrue = cntTrue+1;
    else
      Ir(:,:,:,digit*12+i) = insertText(img,[6 4],num2str(predictedNum),'FontSize',9,'TextColor','red','BoxOpacity',0.4); 
    end 

  end
end
% ���ʂ̕\��
figure;montage(Ir, 'Size', [10,12]); title(['Correct Prediction: ' num2str(cntTrue)]);

%% �I��






%% APP���g�������ފ�̐���
dataTable = table(trainingFeatures, trainingLabels, 'VariableNames',{'features', 'label'});     % 1x324 �̓����x�N�g�� + ���x��   ���A200�s
openvar('dataTable');
classificationLearner
  % �V�K�Z�b�V���� => ���[�N�X�y�[�X����
  % �f�[�^�̃C���|�[�g�F(�f�t�H���g�́A'���ϐ��Ƃ��Ďg�p' ��I��)
  % ��ԉ����A"�\���q"����"����"�֕ύX
  %    �\���q�F�w�K�p�̓����ʁi�s:�f�[�^�� x ��:������ �̐��l�z��j
  %    ���� �F ���t�f�[�^�icategorical array, cell array of strings, character array, logical, or numeric �̗�x�N�g���j
  % ���`SVM��I���� -> �w�K�{�^��
  % Confusion Matrix�̕\��
  %   ��������FN�̃O���[�v�ɕ������A#1����菜��#2~#N-1�̃O���[�v�Ŋw�K��#1�Ńe�X�g�A����#2����菜���A�A�A�A�A���J��Ԃ�
  %   �z�[���h�A�E�g����F�ꕔ�̃f�[�^���A�e�X�g�p�̃f�[�^�Ƃ��Ď�菜�����f�[�^�Ŋw�K�F�e�X�g�p�f�[�^�ɑ΂���藦��]��
  %   ����Ȃ�          �F�S�Ă̊w�K�f�[�^�Ŋw�K�F�p�����S�Ă̊w�K�f�[�^�Ō�藦���v�Z
  % ROC (receiver operating characteristic curve) �Ȑ��\��
  
  % ���f���̃G�N�X�|�[�g�F trainedClassifier
  %      �R���p�N�g���f���F�w�K�f�[�^�̓G�N�X�|�[�g���Ȃ�
%%
Ir = zeros([16,16,3,120], 'uint8');      % ���ʂ��i�[����z��
cntTrue = 0;
for digit = 0:9   % 
  for i = 1:12         % �e�������Ƃ�12���̎菑������
    img = read(testSet(digit+1), i);    % testSet()�́A1����n�܂�̂ŁA+1
    BW = imbinarize(img,graythresh(img));    % 2�l��

    features = extractHOGFeatures(BW,'CellSize',cellSize);
    predictedNum = trainedClassifier.predictFcn(table(features));           % testFeature ��z��ɂ��āA���Ƃł܂Ƃ߂Ĕ������
    
    if predictedNum == digit    %���������ʂ͐F�A��F���͐ԐF
      Ir(:,:,:,digit*12+i) = insertText(img,[6 4],num2str(predictedNum),'FontSize',9,'TextColor','blue','BoxOpacity',0.4);
      cntTrue = cntTrue+1;
    else
      Ir(:,:,:,digit*12+i) = insertText(img,[6 4],num2str(predictedNum),'FontSize',9,'TextColor','red','BoxOpacity',0.4); 
    end 

  end
end
% ���ʂ̕\��
figure;montage(Ir, 'Size', [10,12]); title(['Correct Prediction: ' num2str(cntTrue)]);

%% �I��








%% �������݌v�s���\�� :1��1 �������݌v�i�w�K�퐔�FK(K-1)/2 �j
CodingMat = svmModel.CodingMatrix
%% �ʂ̕������݌v�F 1�Α� �������݌v�i�w�K�퐔�FK �j
svmModel = fitcecoc(trainingFeatures, trainingLabels, 'Coding','onevsall')
CodingMat = svmModel.CodingMatrix

%% �ʂ̕������݌v�F���S2�� �������݌v (��ɑS�ẴN���X���g�p�A�w�K�퐔�F2^(K-1) -1)
svmModel = fitcecoc(trainingFeatures, trainingLabels, 'Coding','binarycomplete')
CodingMat = svmModel.CodingMatrix


%% Copyright 2013-2014 The MathWorks, Inc.
% �摜�f�[�^�Z�b�g
% �g���[�j���O�摜�FinsertText�֐��Ŏ����쐬 (���͂ɕʂ̐����L��)
% �e�X�g�摜�F�菑���̉摜���g�p

% �������݌v�s���\�� :1��1 �������݌v�i�w�K�퐔�FK(K-1)/2 �j
CodingMat = svmModel.CodingMatrix
