%% �e��摜�t�H�[�}�b�g�̓ǂݍ���

%% �����̃t�H�[�}�b�g�̎�������
A=imread('peppers.png');    % �g���q�ɂ��t�@�C���`����������
B=imread('street1.jpg');
C=imread('cameraman.tif');

%% ���ׂĕ\��
imshowpair(A,B,'montage');truesize;shg

%% �����^�[�W���\��
load mri;                   % MAT�t�@�C������A�f�[�^�̓Ǎ���
montage(D,map);truesize;shg % �����^�[�W���\��

%% �C���[�W�r���[�A�[�F�e�풲���p�c�[��
imtool(A)              % �摜�r���[�A�[ �A�v���P�[�V����

%% �C���[�W�u���E�U�F�t�H���_���̗l�X�ȃT�C�Y�E�f�[�^�^�̉摜���ꗗ�\��
imageBrowser(fullfile(matlabroot,'toolbox','images','imdata'));

%% �{�����[���r���[�A�[
load mri           % 128x128x1x27    �摜�̎捞��
D1 = squeeze(D);   % 128x128x27      27���̃X���C�X�摜
volumeViewer(D1)   % �{�����[���r���[���[�̋N��
   % �{�����[���̓Ǎ���
	 % �����̂ɃA�b�v�T���v�����O
	 % �\���F �{�����[�� <=> �X���C�X����

%% �e�N�X�`���}�b�s���O
load clown                % MAT�t�@�C������A�摜�f�[�^'X'�̓Ǎ���
figure;imshow(X,map);     % �摜�\��
[x,y,z]=cylinder;         % �~�����W����
figure;mesh(x,y,z,'edgecolor',[0 0 0]);axis square;  %���W�\��
warp(x,y,z,flipud(X),map);axis square;shg  %�e�N�X�`���}�b�s���O

%% DICOM�u���E�U�[�ɂ��t�@�C���̊m�F
dicomBrowser(fullfile(matlabroot,'toolbox','images','imdata'))

%% �X���C�X�r���[���[
sliceViewer(D1);

%% �I���\�X���C�X�r���[���[
orthosliceViewer(D1);

%% �C�ӂ̐ؒf�ʂ̍쐬�Ɖ���
point = [73 50 15.5]; % �ؒf���ʏ�̓_
normal = [0 15 20]; % �@���x�N�g��
[B,x,y,z] = obliqueslice(D1,point,normal);
surf(x,y,z,B,'EdgeColor','None');

%% �I��

%% 
% Copyright 2018 The MathWorks, Inc.

