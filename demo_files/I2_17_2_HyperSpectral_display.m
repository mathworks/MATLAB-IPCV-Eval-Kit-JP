%% �n�C�p�[�X�y�N�g���摜�̕\��
clc;clear;close all;imtool close all;rng('default');

%% �摜�̓Ǎ��݁E�\��
hcube = hypercube('paviaU.hdr');
% �\���p��RGB�o���h�𒊏o
img = colorize(hcube, 'Method','rgb','ContrastStretching',true);
imshow(img);

%% Copyright 2020 The MathWorks, Inc.
