%% *2.1.4 �O���t�B�b�N�X (�}�[�J�[�`��E�e�L�X�g�`��E�}�`�`��)*
%% �T�v
% MATLAB�ŉ摜�Ƀ}�[�J�[�⒍�߁A�}�`�A�e�L�X�g��`��E�}��������@���Љ�܂��B
% 
% Computer Vision Toolbox?�̊e��`��֐������p���܂��B
%% ������

clear; clc; close all; imtool close all
%% �摜��ǂݍ���

I = imread('visionteam1.jpg');
figure; imshow(I);
%% �l�����o�̃A���S���Y�������s
% �����Ɏg�p���邽�߂ɐl�����o����g���ăo�E���f�B���O�{�b�N�X�̍��W�ƃX�R�A���v�Z���܂��B

detector = peopleDetectorACF;
[bboxes,scores] = detect(detector,I)
%% ���o�����o�E���f�B���O�{�b�N�X��`��
% �͂��߂Ɍ��o�����o�E���f�B���O�{�b�N�X��`�悵�܂��B

Iboxes = insertShape(I,'rectangle',bboxes);
imshow(Iboxes)
%% 
% �o�E���f�B���O�{�b�N�X�̘g�̑�����F��ς��Ă݂܂��B

Iboxes = insertShape(I,'rectangle',bboxes,"LineWidth",5,"Color","red");
imshow(Iboxes)
%% ���o�����o�E���f�B���O�{�b�N�X��`��(�L���v�V������ǉ�)
% ���Ɋe���o���ʂ̃X�R�A���L���v�V�����Ƃ��ăo�E���f�B���O�{�b�N�X���������܂��B

Iout = insertObjectAnnotation(I,'rectangle',bboxes,scores);
figure
imshow(Iout)
%% 
% �����X�R�A�ƒႢ�X�R�A�ňقȂ�F�ɂȂ�悤�ɂ��܂��B

% �J���[�}�b�v�𐶐�
cmap = jet;

% �X�R�A��0-255�ɐ��K��
scoreNorm = im2uint8(mat2gray(scores));

% �J���[�}�b�v�Ɋ��蓖��
colors = im2uint8(reshape(ind2rgb(scoreNorm,cmap),[],3));

% �o�E���f�B���O�{�b�N�X��}�������摜����
Iout = insertObjectAnnotation(I,'rectangle',bboxes,scores,...
    "LineWidth",3,"Color",colors);
figure
imshow(Iout)
%% �e�L�X�g�}��
% �e�L�X�g��}�����܂��B���{��ő}�����邱�Ƃ��\�ł��B

listTrueTypeFonts % �t�H���g�̃��X�g�m�F
Iout2 = insertText(Iout,[1,1],'�l�����o���ʂ̉���',...
    'Font','MS UI Gothic','FontSize',25,...
    'BoxColor','blue','TextColor','white');
figure, imshow(Iout2);
%% �}�[�J�[�}��
% �}�[�J�[��`��E�}�����܂��B
% 
% ��Ƃ��Č��o���ꂽ�l�����ORB�����𒊏o���A���̓����_��`�悵�܂��B

points = detectORBFeatures(rgb2gray(I),'ROI',bboxes(3,:));

% �X�R�A��0-255�ɐ��K��
metricNorm = im2uint8(mat2gray(points.Metric));

% �J���[�}�b�v�Ɋ��蓖��
colors = im2uint8(reshape(ind2rgb(metricNorm,parula),[],3));

% �`��
Iout3 = insertMarker(Iout2,points.Location,"plus","Color",colors);
figure, imshow(Iout3);
%% �}�`�}��
% �C�ӂ̐}�`��}�����邱�Ƃ��ł��܂��B

% �����_�̏d������菜��
loc = unique(double(points.Location),'rows');
% �O�p�`����
DT = delaunayTriangulation(loc(:,1),loc(:,2));
%�ʕ���v�Z
C = convexHull(DT);
% [x1,y1,x2,y2,...]�Ƃ����x�N�g���ɕϊ�
polyPos = reshape([DT.Points(C,1),DT.Points(C,2)]',1,[]);
% �|���S���Ƃ��đ}��
Iout4 = insertShape(Iout3,'Polygon',polyPos,'LineWidth',5);

% �猟�o
faceDetector = vision.CascadeObjectDetector();
bboxesFace = faceDetector(rgb2gray(I));
% �~��`�悷�邽�߂�[x,y,r]�̃x�N�g���ɕϊ�
posCir = [bboxesFace(:,1:2)+bboxesFace(:,3:4)/2 bboxesFace(:,3)/2];
Iout5 = insertShape(Iout4,'Circle',posCir,'LineWidth',5);

figure, imshow(Iout5);
%% �܂Ƃ�
% MATLAB�ŉ摜�Ƀ}�[�J�[�⒍�߁A�}�`�A�e�L�X�g��`��E�}��������@���Љ�܂����B
% 
% �摜�����A�R���s���[�^�[�r�W�����A�f�B�[�v���[�j���O�Ȃǂ̏������ʂ̉����ɂ��𗧂Ă��������B
%% �Q�l
%% 
% * <https://jp.mathworks.com/help/vision/ref/inserttext.html |insertText|>
% * <https://jp.mathworks.com/help/vision/ref/insertobjectannotation.html |insertObjectAnnotation|>
% * <https://jp.mathworks.com/help/vision/ref/insertshape.html |insertShape|>
% * <https://jp.mathworks.com/help/vision/ref/insertmarker.html |insertMarker|>
%% 
% Copyright 2020 The MathWorks, Inc.
% 
%