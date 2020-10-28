%% HOG (Histogram of Oriented Gradient) ������ ��
%  ����؁i2���؁j ���g�����A�菑�������̎���
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

%% [���ޖ؂̍\�z]�Ffitctree���g�p
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
% ���ޖ؂̊w�K
treeModel = fitctree(trainingFeatures, trainingLabels, 'MaxNumSplits',4)

%% ���ރc���[�r���[�A�[�ŁA���������c���[��\��
%    x�ԍ��́A�����ʂ̔ԍ�
view(treeModel, 'mode','graph');

%% [����] �쐬�������ފ�Ŏ菑������(120��)�����ʥ�\���Fpredict()
Ir = zeros([16,16,3,120], 'uint8');      % ���ʂ��i�[����z��
cntTrue = 0;
for digit = 0:9   % 
  for i = 1:12         % �e�������Ƃ�12���̎菑������
    img = read(testSet(digit+1), i);    % testSet()�́A1����n�܂�̂ŁA+1
    BW = imbinarize(img,graythresh(img));    % 2�l��

    testFeatures = extractHOGFeatures(BW,'CellSize',cellSize);
    predictedNum = predict(treeModel, testFeatures);           % testFeature ��z��ɂ��āA���Ƃł܂Ƃ߂Ĕ������
    
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

%%


%% �A���T���u���w�K (ClassificationBaggedEnsemble �N���X���Ԃ�)
%   �o�M���O����� => �����_���t�H���X�g �A���S���Y�����g�p
template = templateTree('MaxNumSplits', 20);
bagModel = fitcensemble(...
	trainingFeatures, trainingLabels, ...
	'Method', 'Bag', ...
	'NumLearningCycles', 30, 'Learners', template);

%% bagModel.Trained�́A CompactClassificationTree�N���X�̃Z���z��
%       Children : �m�[�h�ԍ����ɁA���̃m�[�h���Ȃ����Ă���2�̃m�[�h�ԍ��B�I�[�m�[�h�Ɋւ��Ă�0 0 ������
%       CutPredictor : �e�m�[�h�ł̕���ɗp��������ʔԍ�
%       CutPoint : �����臒l (�I�[�m�[�h�Ɋւ��ẮANaN������)
%       NodeClass : �e�m�[�h�ł̕��ނ��ꂽ�N���X
view(bagModel.Trained{3})
view(bagModel.Trained{3}, 'mode','graph')




%% ���ފw�K��A�v���P�[�V�����̎g�p
%   �o�M���O����؂́A�����_���t�H���X�g
%   �\���̂̃����o�[�Ƃ��āAClassificationEnsemble (CompactClassificationEnsemble�N���X)  ���Ԃ�
%   �eClassificationEnsemble.Trained{k}���ACompactClassificationTree�N���X�̃I�u�W�F�N�g
dataTable = table(trainingFeatures, trainingLabels, 'VariableNames',{'features', 'label'});     % 1x324 �̓����x�N�g�� + ���x��   ���A200�s
openvar('dataTable');
classificationLearner

% �R���p�N�g���f���̃G�N�X�|�[�g�FtrainedClassifier
view(trainedClassifier.ClassificationEnsemble.Trained{1}, 'mode','graph')

%% [����] �쐬�������ފ�Ŏ菑������(120��)�����ʥ�\���FtrainedClassifier.predictFcn()
Ir = zeros([16,16,3,120], 'uint8');      % ���ʂ��i�[����z��
cntTrue = 0;
for digit = 0:9   % 
  for i = 1:12         % �e�������Ƃ�12���̎菑������
    img = read(testSet(digit+1), i);    % testSet()�́A1����n�܂�̂ŁA+1
    BW = imbinarize(img,graythresh(img));    % 2�l��

    features = extractHOGFeatures(BW,'CellSize',cellSize);
		predictedNum = trainedClassifier.predictFcn(table(features));    % testFeature ��z��ɂ��āA���Ƃł܂Ƃ߂Ĕ������
 
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




%% Copyright 2013-2014 The MathWorks, Inc.
% �摜�f�[�^�Z�b�g
% �g���[�j���O�摜�FinsertText�֐��Ŏ����쐬 (���͂ɕʂ̐����L��)
% �e�X�g�摜�F�菑���̉摜���g�p
