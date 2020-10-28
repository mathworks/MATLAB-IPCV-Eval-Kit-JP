%% �؂̎������J�E���g��Ԃ����̕��ς̑傫��
% ������
clear;clc;close all;imtool close all

%% �摜�f�[�^��Ǎ���
I = imread('I2_08_1_1895cr.jpg');
figure;imshow(I);

%% �Q�l�摜���쐬���A���̂Ɣw�i������ %%%%%%%%%%%%%%%%%%
% �O���[�X�P�[���֕ϊ�
G = rgb2gray(I);
figure;imshow(G);

%% �P�x�̃q�X�g�O�������m�F
figure;imhist(G);

%% �P�x�ɂ���l�� (�w�i��0�A���̂�1��2�l�摜�쐬)
BW = G < 180;      %140����10���A"�l�̃C���N�������g����уZ�N�V�������s"
imshow(BW);shg;

%% �G�b�W���o
BWe = edge(G,'canny', [0.04 0.06], 3);
imshow(BWe);shg;   %�g�債�ė֊s���Ȃ����Ă��邱�Ƃ��m�F

%% �����t�H���W�[�����F���ň͂܂�Ă���̈�𖄂߂�
BWf1 = imfill(BWe, 'holes');
imshow(BWf1); shg;

%% �����t�H���W�[�����F�؂�Ă��镔�����Ȃ�
BWb = bwmorph(BWf1, 'bridge');
imshow(BWb); shg;                     % �Ȃ��������Ƃ��m�F

%% �ēx�A���ň͂܂�Ă��镔���𖄂߂�
BWf2 = imfill(BWb, 'holes');
imshow(BWf2); shg;

% �����t�H���W�[�����F�ׂ��Ȑ�(�m�C�Y)���폜�F�I�[�v������ (���k��ɖc��)
% �i���ɁAbwareaopen()�֐��ōs�����Ƃ��\ �j
%% ���k����
BWe = bwmorph(BWf2, 'erode');
figure;imshow(BWe); shg;

%% �c������
BWd = bwmorph(BWe, 'dilate');
figure;imshow(BWd); shg;

%% �e�̈�iblob�F���������j�̌`�󑪒� (�ʐρE���S�_)
stats=regionprops('table', BWd, 'Area', 'Centroid')  % R2015a �Ńe�[�u���o�͂ɑΉ�

%% ��
size(stats, 1)

%% �ʐς̃q�X�g�O�������v���b�g
figure;histogram([stats.Area])

%% �C���[�W�̉�� �A�v���P�[�V���� �� BWd��Ǎ���

%% �I��



%% Copyright 2013 The MathWorks, Inc.
%    Masa Otobe (masa.otobe@mathworks.co.jp)
% �K�v�ȃt�@�C���FI2_08_1_1895cr.jpg
