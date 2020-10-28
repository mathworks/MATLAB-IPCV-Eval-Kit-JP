%% ���Ԃ̌��׌��o
% ������
clc;close all;imtool close all;clear;

%% [�摜�̓Ǎ���]
G = imread('I2_01_3_gear7g.jpg'); % �ϐ��錾�s�v�B�e�Ղȑ������z��戵��
imtool(G);                   % �e�Ղȉ���

%% [�O����] ��l(����)�摜�ɕϊ� (�v���b�g->histogram�Ŋm�F or imhist(G) )
BW = G > 130;     % �񎟌��̔z��ƁA���l�̔�r�B����臒l�ݒ�FBW=im2bw(G, graythresh(G));     150
imtool(BW);       % �s�N�Z���l���m�F (0��1�́A2�l�摜)

%% [�t�B���^����]�g�b�v�n�b�g �t�B���^�����ŁA���̕����𒊏o �i���摜 - Opening�摜�j
%BWtoph = imtophat(BW, strel('Disk',30,8));         %�g�b�v�n�b�g �t�B���^�������P�̊֐��Ŏ��s

BWerode = imerode(BW, strel('Disk',30,8));          % ���k
imshow(BWerode); shg;
%% 
BWdilate = imdilate(BWerode, strel('Disk',30,8));   % �c��
figure;imshow(BWdilate); shg;

%%
BWtoph = imsubtract(BW, BWdilate);       % ���摜 - Opening�摜
imshow(BWtoph); shg;

%% [�㏈��] �ׂ��ȃm�C�Y�̏���
BWclear = bwareaopen(BWtoph, 50); % 50�s�N�Z���ȉ��̂��̂��폜
imshow(BWclear); shg;

%% [�r�����ʂ̉���] �����܂ł̌��ʂ��A���ׂĕ\��
figure; imshowpair(BW, BWclear, 'montage');shg;

%% [�r�����ʂ̉��] �Q�̉摜���d�˂ĕ\��
imshowpair(BW, BWclear);shg;   % ���F�ω��Ȃ������A�΁F���̉摜�݂̂ɑ���

%% [�v��] �e���̖ʐςƒ��S�_�̑���
% imageRegionAnalyzer;
stats = regionprops('table', BWclear, 'Area', 'Centroid')  % R2015a �Ńe�[�u���o�͂ɑΉ�

%% [�O���t��] �q�X�g�O�����̕\��   �͈͂�[�ŏ�:�ő�]�Ŏw��
figure; histogram([stats.Area], [1:179]);

%% [���ʂ̉���]
ind = find([stats.Area] < 100);  % �x�N�g���Ɛ��l�̔�r
Gresult2 = insertShape(G, 'Circle', [stats.Centroid(ind,:) 18], 'LineWidth',4, 'Color','red', 'Opacity',1);
Gresult3 = insertText(Gresult2, [10, 10], ['Defect Tooth: indicated by Red Circle'], 'FontSize', 30, 'BoxColor','red', 'BoxOpacity',1);
imshow(Gresult3); shg

%% [�I��]
%% [���|�[�g����]

%% Copyright 2014 The MathWorks, Inc.
%        Masa Otobe (masa.otobe@mathworks.co.jp)
