% �摜���炨�Ă̖ʐς␔�����߂�
% ������
clear; clc, close all, imtool close all;
% ��s�Â��ԂɎ��s

%% �摜��2�l������ %%%%%
I = imread('coins.png');  % �t�@�C������摜�Ǎ��� (�ϐ�I��)
figure; imshow(I);   % Window���쐬���A�摜�̕\��

figure; imhist(I);   % �q�X�g�O�����\��
I2 = I > 100;        % �召��r���Z�ɂ��摜�̓�l��
figure; imshow(I2);
I3 = imfill(I2, 'holes'); % ���̓h��Ԃ�
figure; imshow(I3);

%% �ʂ�2�l�������ƁA"�ʒu"��A"�ʐ�"�̕��ς̎Z�o %%%%%
clear all; clc, close all, imtool close all;
I = imread('rice.png'); % �t�@�C������摜�Ǎ���
figure; imshow(I);      % �摜�̕\��

figure; imhist(I);      % �q�X�g�O�����\��

%%
a = 79;
imshow(I>a);shg;        % �Θb�I�ɓK�؂�臒l�̒T��
%%
figure; imshow(I>150);
figure; surf(double(I));shading interp; % �\�ʃv���b�g
                                        % �\�����݂₷��

Ierode=imerode(I, ones(15));     % ���k�����ɂ��ė��̏���
figure;imshow(Ierode);
figure; ...
surf(double(Ierode),'EdgeColor','none');% �w�i�\�ʃv���b�g

I2 = I-Ierode;                             % �w�i�̏���
figure; surf(double(I2));shading interp; % �\�ʃv���b�g

figure; imtool(I2);           % imtool�Ńq�X�g�O�����m�F
Ibw = I2 > 50;
figure; imshow(Ibw);
Ibw=bwareaopen(Ibw, 4);       % �ׂ��ȃm�C�Y�̏���
figure; imshow(Ibw);
Iclr=imclearborder(Ibw);      % �؂�Ă���(�O���ڐG)�Ă̏���
figure; imshow(Iclr);
stat=regionprops('table', Ibw, 'Area', 'Centroid')  % struct/table, �ʐρA[x���W, y���W]
A=[stat.Area]                 % ���܂����e�ʐ�
mean(A)                       % �ʐς̕���

histogram(A);           % ��������A�����[�N�X�y�[�X�őI����A
                   % �c�[���X�g���b�v��hist�I��
title('�ʐϕ��z', 'FontSize',16);
%% �I��




%% Copyright 2013 The MathWorks, Inc.
% This is a demo for thresholding, morphological image processing, blob analysis
%
% Original version can be found by the following command
%     web([docroot '/images/examples/correcting-nonuniform-illumination.html'])
% or in the following URL.
%     http://www.mathworks.com/help/releases/R2012b/images/examples/correcting-nonuniform-illumination_ja_JP.html

