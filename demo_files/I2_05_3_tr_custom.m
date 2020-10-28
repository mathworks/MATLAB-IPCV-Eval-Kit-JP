clear all; close all; clc;

%% �J�X�^���ϊ��t�H�[���ɂ��􉽊w�I�ϊ�
%    p2c.m �� c2p.m  ���g�p

%% �摜�̓��͂ƕ\��
load topo
I = topo(1:90,:);
figure
imagesc(I(end:-1:1,:),'CDataMapping','scaled');
colormap(topomap1)

%% �J�X�^���ϊ��t�H�[���̍쐬
T = maketform('custom',2,2,@p2c,@c2p,[]);
udata = [-pi pi];   % ���͉摜�ɑ΂���X���͈̔�
vdata = [0 90];   % ���͉摜�ɑ΂���Y���͈̔�
xdata = [-90 90];   % �o�͉摜�ɑ΂���X���͈̔�
ydata = [-90 90];     % �o�͉摜�ɑ΂���Y���͈̔�


%% �􉽊w�I�ϊ���\��
b = imwarp(I,T,'cubic','UData',udata,...
    'VData',vdata,'XData',xdata,'YData',ydata,...
    'Size',[180 180],'FillValues',0);

figure
imagesc(b,'CDataMapping','scaled');
colormap(topomap1)

%% 
% Copyright 2014 The MathWorks, Inc.
