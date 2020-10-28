%% HOG (Histogram of Oriented Gradient) ������ ��
%  k���ρFk-Means Clustering ���g�����A�菑�������̕���
clear;clc;close all;imtool close all

% �菑�������摜�i12��x10������j�ւ̐�΃p�X��ݒ�
pathData = [toolboxdir('vision'), '\visiondata\digits\handwritten']
trainSet  = imageSet(pathData, 'recursive');

%% �菑�������摜�������^�[�W���\�� (12�� x 10������)
figure;montage([trainSet.ImageLocation], 'Size', [10,12]);

%% 4x4�̃Z���T�C�Y���g�p (324�����x�N�g��)
cellSize = [4 4];
hogFeatureSize = 324;                   % length(hog_4x4)

%% k���σN���X�^�����O
% 10��������trainingFeatures ���i�[����z������炩���ߍ쐻
trainingFeatures  = zeros(10*12,hogFeatureSize, 'single');

% HOG�����ʂ𒊏o
for digit = 1:10   % 1=>����'0'
  for i = 1:12         % �e�菑���������Ƃ�12���̃g���[�j���O�p�摜
    img = read(trainSet(digit), i);  %�g���[�j���O�摜�̓Ǎ���
    img = imbinarize(img,graythresh(img));   % ��l��
             
    trainingFeatures((digit-1)*12+i,:) = extractHOGFeatures(img,'CellSize',cellSize);
  end
end
% K���σN���X�^�����O�̎��s
result = kmeans(trainingFeatures, 10)    %10�̃O���[�v�ɕ���

%% 10�̃N���X�^���ɁA���ʂ̕\��
figure; Ir = [];
for k = 1:10
  for digit = 0:9
    for i = 1:12         % �e�������Ƃ�12���̎菑������
      if result((digit)*12+i) == k
        img = read(trainSet(digit+1), i);                     
        Ir = [Ir img];
      end
    end
  end
  subplot(10,1,k); imshow(Ir); Ir = [];
end
%% �I��













%% �ʌ`���̌��ʕ\��
Ir = zeros([16,16,3,120], 'uint8');      % ���ʂ��i�[����z��
for digit = 0:9
  for i = 1:12         % �e�������Ƃ�12���̎菑������
    img = read(trainSet(digit+1), i);                     
    Ir(:,:,:,(digit)*12+i) = insertText(img,[6 4],char(64+result((digit)*12+i)),'FontSize',10,'TextColor','blue','BoxOpacity',0.4);
  end
end
% �\��
figure;montage(Ir, 'Size', [10,12]);

%% Copyright 2013-2014 The MathWorks, Inc.
% �摜�f�[�^�Z�b�g
% �g���[�j���O�摜�FinsertText�֐��Ŏ����쐬 (���͂ɕʂ̐����L��)
% �e�X�g�摜�F�菑���̉摜���g�p
