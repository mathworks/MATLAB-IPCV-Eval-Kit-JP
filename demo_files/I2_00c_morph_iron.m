clear all;clc;close all;imtool close all

%% �I���W�i���摜�̃��[�h�ƕ\��
Iorg=imread('I2_00c_iron.tif');
imtool(Iorg);      % �R���g���X�g�������j���[�Ńq�X�g�O�����m�F
%title('Original Image','Fontsize',12,'Fontweight','bold')

%% 2�l�� (���x���x��180��臒l�Ƃ���B��������O�i��)
I = Iorg<180; 
figure; imshow(I)
title('�Q�l��','Fontsize',12,'Fontweight','bold')

%% �א�������(skel)
I = bwmorph(I,'skel','inf');
figure; imshow(I)
title('�א���','Fontsize',12,'Fontweight','bold')

%% �}���̏���(spur)
I = bwmorph(I,'spur','inf');
figure; imshow(I)
title('�}���̏���','Fontsize',12,'Fontweight','bold')

%% �Ǘ��I�u�W�F�N�g�̏���(clean)
I = bwmorph(I,'clean');
figure; imshow(I)
title('�Ǘ��I�u�W�F�N�g�̏���','Fontsize',12,'Fontweight','bold')

%% ���]
Ir=~I;
imshow(Ir);shg;

%% �e�̈���ŗL�̔ԍ��Ń��x�����O�i�w�i�� 0�j
L = bwlabel(Ir,4);	% �e�̈���ŗL�̔ԍ��Ń��x�����O (4�A��)
imtool(L);          % �e�̈�̒l���m�F

%% ���x���ԍ����ɐF����
figure; imagesc(L); colormap(jet)
title('���x�����O','Fontsize',12,'Fontweight','bold')

%% �C���[�W�̗̈��� �A�v���P�[�V����

%% �̈�v���p�e�B�̑��� (�ʐρE���S�_(�d�S))
stats = regionprops(L, 'Area', 'Centroid')

%% ��Ԗڂ̗̈�̑��茋��
stats(1)

%% �摜��ɖʐς�\��
hold on
for x = 1:length(stats)
	if stats(x).Area > 50	% 50�s�N�Z���ȏ�̗̈�̂ݕ\��
		xy = stats(x).Centroid;
        plot(xy(1), xy(2), 'r*');  %���S�ʒu�ɐԂ́��}�[�N���L��
		text(xy(1)+4, xy(2), num2str(stats(x).Area));
	end
end
hold off
title('�v���p�e�B�Z�o','Fontsize',12,'Fontweight','bold');shg;

%% ���v����
A = [stats.Area]     % ���܂����e�ʐ�
%% �ʐς̕���
mean(A)
%% �q�X�g�O�����\��
figure;histogram(A)

%% �[���؂�Ă���̈���폜
L1 = imclearborder(L,4);
figure;imagesc(L1),colormap(jet)

%% 
% Copyright 2014 The MathWorks, Inc.
