clear;clc;close all;imtool close all

%% 2�l�摜���̑S�̈�̋��E���g���[�X
G = imread('coins.png');
figure;imshow(G);
BW = G > 100;
figure;imshow(BW);

%% boundarymask�֐��̗�:
b = boundarymask(BW);         % ���E���}�X�N�Ƃ��Đ���
Ib = imoverlay(G, b, 'g');    % �}�X�N���摜�ɏ㏑��
figure; imshow(Ib);           % �\��

%% bwboundary�֐��̗�
b = bwboundaries(BW, 'noholes') % ���̓g���[�X�����Bb��XY���W�̃��X�g
figure;imshow(G);
hold on;
visboundaries(b, 'Color','g');  % Figure��Ō��摜��ɏ㏑��
hold off


%% bwtraceboundary : 2�l�摜���̈�̋��E���g���[�X
G = imread('coins.png');
figure;imshow(G);
BW = imbinarize(G);
imtool(BW);

dim = size(BW)
col = round(dim(2)/2)-90      % �g���[�X�J�n�_���W
row = min(find(BW(:,col)))    % �g���[�X�J�n�_���W
b = bwtraceboundary(BW,[row, col],'N');  % ���E��̓_(60,26)���狫�E�ɉ����ăg���[�X
hold on;
plot(b(:,2),b(:,1),'g','LineWidth',3);    % visboundaries �̎g�p���\
plot(col, row,'ro','LineWidth', 6);
hold off;
%% ���摜�ɏ㏑��
figure;imshow(G);shg;
hold on;
plot(b(:,2),b(:,1),'g','LineWidth',3);
plot(col, row,'ro','LineWidth', 6);
hold off;


%% bwperim : �֊s������2�l�摜�𐶐�
G = imread('coins.png');
figure;imshow(G);
BW = G > 100;
figure;imshow(BW);

BWb = bwperim(BW);
imshow(BWb);
%% ���摜��ɏ㏑��
G(BWb) = 0;
I = cat(3, G+ uint8(BWb*255), G, G);
figure;imshow(I);

%% �I��



%% insertShape���g�����ꍇ
G = imread('coins.png');
figure;imshow(G);
BW = G > 100;
figure;imshow(BW);
b = bwboundaries(BW, 'noholes'); % ���̓g���[�X����
I1 = insertShape(G, 'Line', reshape([b{1}(:,2),b{1}(:,1)]',1,[]), 'LineWidth',1, 'SmoothEdges',false);
imtool(I1)



% Copyright 2014 The MathWorks, Inc.
