clear;clc;close all;imtool close all
%% 1����Low Pass Filter�݌v
N = 12;            % ����
Fpass = 0.3;       % �ʉߑш���g��
Fstop = 0.35;      % �Ւf�ш���g�� 
Wpass = 1;         % �ʉߑш�d��
Wstop = 1;         % �Ւf�ш�d��
b = firls(N,[0 Fpass Fstop 1],[1 1 0 0],[Wpass Wstop]) %�ŏ����  ���`�ʑ� FIR �t�B���^�[�̐݌v (���z��������̏d�ݕt���ϕ����덷���ŏ���)
%% 1�����t�B���^���g�������\��
freqz(b,1) 

%% ��L�̂��Ƃ��AFDATool�ɂ��݌v����ꍇ
filterDesigner       % �݌v��������A�t�@�C�� -> �G�N�X�|�[�g

%% 1�����t�B���^��2������
H2 = ftrans2(b);    % 1����FIR�t�B���^����A�~�Ώ�2�����t�B���^�݌v
figure,freqz2(H2)   % 2�����t�B���^���g�������\��

%% �摜�̓Ǎ���
I = imread('cameraman.tif');
figure;imshow(I);
%% �t�B���^����
If = imfilter(I,H2);
imshow([I;If]);shg

%% 
% Copyright 2014 The MathWorks, Inc.

