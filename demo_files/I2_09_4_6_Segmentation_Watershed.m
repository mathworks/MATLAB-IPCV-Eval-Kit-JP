%% �������Ă������ʂɔF�����A���E�ʐς̌v���A�ʐϕ��z�E���ϖʐς̌v�Z
%    ������
clear;clc;close all;imtool close all

%% �C���[�W�̓ǂݍ���
I = imread('I2_09_4_6_DSC_1903cr.jpg');
figure;imshow(I);                          % ;���R�}���h���

%% Final�摜���m�F
figure;imshow(imread('I2_09_4_6_DSC_1903result.jpg'));

%% �O���[�X�P�[���֕ϊ�
G = rgb2gray(I);
imtool(G);

%% �P�x�ɂ���l��
figure;imhist(G);
%%
BW = G < 195;
imshow(BW);shg

%% �ׂ����m�C�Y�̏���
BWclean = bwareaopen(BW, 20);
figure;imshow(BWclean);

%% ���̓h��Ԃ�
BWfill = imfill(BWclean, 'holes');
figure;imshow(BWfill);

%% ��ʒ[�̂����Ă�����̂�����
BWclear = imclearborder(BWfill);
figure; imshow(BWclear);

%% �����ϊ��̎��s�i2�l�摜�G�b�W�Ɍ��z������j
BWclear_b = ~BWclear;
imshow(BWclear_b);shg;         %�w�i�ƑO�i�̔��]����
%%
BWdist = bwdist(BWclear_b);
figure;imshow(BWdist,[]);shg;  %�����ϊ�(�����̈�܂ł̋���)�̌���
%%
BWdist = -BWdist;
imshow(BWdist, []);shg;        %�w�i�ƑO�i�̔��]����
%   ���q�̈���ŁA��(�O�i)�܂ł̋��������̉�f�ʒu�̒l
%   �w�i�̈�́A�l='0'

%% �o�b�N�O�����h���̈�Ɋ܂܂�Ȃ��悤�ɁA-Inf�Ɏw��
BWdist(BWclear_b) = -Inf;         %BWdist�Ŕ����Ȃ��Ă���w�i������-Inf�ɂ���B
imshow(BWdist, []);shg;

%% ��̗��q�������ɕ��������̂�h�����߂ɁA�e���q���ɏ��̈���P��
figure;imshow(imregionalmin(BWdist));  %�Ǐ������𔒂��\��
%%
BWhmin = imhmin(BWdist, 2);            %�Ǐ�������2�����グ��
figure;imshow(imregionalmin(BWhmin));  %�Ǐ��������ēx�����\��

%% �E�H�[�^�[�V�F�b�h�ϊ����s���A�ɏ��_���ɗ̈敪���E�\��
%figure;surf(double(BWhmin));shading interp; %�\�ʃv���b�g
%
BWshed = watershed(BWhmin);

% �\��
imtool(BWshed,[]);   %�̈斈�ɔԍ�������U���Ă���̂��m�F   
                     %�w�i�͗̈�1
                     %�̈�0 �͕�����(��)�F����̕�����̈�ɑ����Ȃ��B
BWlabel = label2rgb(BWshed,'jet');
imshow(BWlabel);shg                %�̈悲�Ƃɕʂ̐F�ŕ\�� (�̈�0�́A���F)

%% regionprops�֐��ɂ��A�e�G���A�����v�Z
stat = regionprops(BWshed, 'Area', 'Centroid')
stat(10)
stat(1) = [];      % �w�i����̃f�[�^������

%% ���ʂ̕\��
BWshed(BWshed==1)=0;    % �w�i(�̈�ԍ�1)��̈�ԍ�0�֕ύX
boundaries = bwboundaries(BWshed, 'noholes'); % �e�̈�̋��E�𒊏o�i���̓g���[�X�����j
figure;imshow(I);
hold on;
for k=1:size(boundaries)
   b = boundaries{k};
   plot(b(:,2),b(:,1),'r','LineWidth',2);
end
hold off

%% �I��















%% �Q�l (�ǉ��̏���) %%%%%%%%%%%%%%%
%% ���q�̌�
size(stat, 1)
%% ���q�̌X�̖ʐς̕���
mean([stat.Area])
%% ���q�̌X�̖ʐ�
A=[stat.Area]
%% �q�X�g�O�����\��
figure;histogram(A,1700:100:2500);
%% ���ʐ�
sum([stat.Area])

%% �֊s���o�̕ʂ̃X�N���v�g(BWlabel�̔�������(�̈�ԍ�0)�𒊏o)
BWperi_t = (BWlabel(:,:,1) == 255) & ...
           (BWlabel(:,:,2) == 255) & ...
           (BWlabel(:,:,3) == 255);
imshow(BWperi_t);shg;
% ���₷�����邽�߂ɗ֊s��c�������ő���
BWperi = bwmorph(BWperi_t, 'dilate');
figure;imshow(BWperi);
% �֊s��Ԑ��ŏ㏑��
BWfalse = false(size(BWperi));
Iperi = I;                       % ���͉摜���R�s�[
Iperi(cat(3,BWfalse, BWperi, BWfalse)) = 255;
Iperi(cat(3,BWperi,  BWfalse,BWperi )) = 0;
Iperi(cat(3,BWperi, BWfalse, BWfalse)) = 255;
Iperi(cat(3,BWfalse,  BWperi,BWperi )) = 0;
imshow(Iperi);shg;
% �X�̗��q�́A���S�_�Ɩʐς��㏑���\��
centroids = cat(1,stat.Centroid);  %���S�_�̍��W�x�N�g�����쐬
areas     = cat(1, stat.Area);     %�ʐσx�N�g���̍쐬
Ifinal = insertMarker(Iperi, centroids, 'star', 'Color','green', 'Size',5);  %���S�ʒu�ɗ΂́��}�[�N���L��
Ifinal = insertText(Ifinal, centroids,  cellstr(num2str(areas)), 'BoxOpacity',0, 'FontSize',18); %�ʐς̒l��������
imshow(Ifinal);shg;

%% Copyright 2013 The MathWorks, Inc.
%    Masa Otobe (masa.otobe@mathworks.co.jp)

% �K�v�ȃt�@�C�� : DSC_1903cr.jpg, DSC_1903result.jpg
