%% �����_��p�������̂̌��o
clc;clear;close all;imtool close all;

%% �������镨�̂̉摜�̓Ǎ��ݥ�\��
Iref = imread('I4_02_1_p1a.jpg');
figure; imshow(Iref);

%% �񌟍��摜�̓Ǎ��ݥ�\��
I = imread('I4_02_1_p2a.jpg');
figure;imshow(I);

%% ���ꂼ��̉摜�ŁA�����_���o�E�\��
Gref = rgb2gray(Iref);        % �O���[�X�P�[���֕ϊ�
G    = rgb2gray(I   );

PointsRef = detectBRISKFeatures(Gref);  % �����_�̌��o
PointsI   = detectBRISKFeatures(G);

subplot(1,2,1); imshow(Iref); hold on;
plot(PointsRef.selectStrongest(100));     % ���100�|�C���g���v���b�g
subplot(1,2,2); imshow(I   ); hold on;
plot(PointsI.selectStrongest(100)); hold off; shg;

%% ������(Feature, ValidPoints)���o�A�\��
[FeaturesRef, vPointsRef] = extractFeatures(Gref, PointsRef, 'Method', 'BRISK');
[FeaturesI,   vPointsI  ] = extractFeatures(G,    PointsI,   'Method', 'BRISK');

subplot(1,2,1); imshow(Iref); hold on;
plot(vPointsRef.selectStrongest(100),'showOrientation',true);
subplot(1,2,2); imshow(I); hold on;
plot(vPointsI.selectStrongest(100),'showOrientation',true);hold off;shg;

%% ������(FeaturesRef,FeaturesI)�̃}�b�`���O�E���ʕ\��   (�ꕔ outlier ������)
indexPairs = matchFeatures(FeaturesRef, FeaturesI, 'MatchThreshold',30, 'MaxRatio',0.8);

matchedPointsRef = vPointsRef(indexPairs(:, 1));  % Iref��̈ʒu��o
matchedPointsI   = vPointsI(  indexPairs(:, 2));  % I��̈ʒu��o
figure;
showMatchedFeatures(Iref, I, matchedPointsRef, matchedPointsI, 'montage'); truesize;

%% �ϊ��s��̐���(MSAC)�ƁA��Ή��_�̏����A���Ή��_�̕\��
[tform, inlierIndex] = ...
    estimateGeometricTransform2D(matchedPointsRef, matchedPointsI, 'projective', 'MaxDistance', 3);

inlierPointsRef = matchedPointsRef.Location(inlierIndex,:);
inlierPointsI   = matchedPointsI.Location(inlierIndex,:);

figure; showMatchedFeatures(Iref, I, inlierPointsRef, inlierPointsI, 'montage');


%% ����ꂽ�ϊ��s��̕\��
tform.T

%% ����ꂽ�s��ŗ̈��ϊ����A���o������������ň͂�
PolygonRef = bbox2points([1 1 size(Iref, 2) size(Iref, 1)]);   %���摜�̎l��
newPolygonRef = transformPointsForward(tform, PolygonRef);    %�ϊ���̎l��

foundObj = insertShape(I, 'Polygon', reshape(newPolygonRef',[1 8]), 'Color','red', 'LineWidth',10);
figure; imshow(foundObj);

%% �I��
% % Copyright 2020 The MathWorks, Inc.
