%% 3�����{�����[���f�[�^�̏���

%% ������
clear; close all; clc;

%% ���a5��10�̋��̂��쐬
[x,y,z] = meshgrid(1:50,1:50,1:50);
bw1 = sqrt((x-10).^2 + (y-15).^2 + (z-35).^2) < 5;
bw2 = sqrt((x-20).^2 + (y-30).^2 + (z-15).^2) < 10;
bw = bw1 | bw2;
figure
isosurface(bw)
alpha 0.3;
axis equal;

%% �d�S�Ɣ��a���v�Z
s = regionprops3(bw,"Centroid","PrincipalAxisLength");
centers = s.Centroid
diameters = mean(s.PrincipalAxisLength,2)
radii = diameters/2

[x,y,z] = sphere;
hold on 
for k = 1:size(s,1)
    surf(x*radii(k)+centers(k,1),y*radii(k)+centers(k,2),z*radii(k)+centers(k,3));
end

%% Brain Scan Demo (NIfTI image processing)
% �{�f���ł́A3�����̔]�X�L����NIfTI�f�[�^��ǂݍ��݁A
% �]�����݂̂̃{�����[���\�������݂܂�

%% NIfTI�摜�̓ǂݎ��Ή�(R2017b)
% NIfTI (Neuroimaging Informatics Technology Initiative) 
D = niftiread('brain.nii');
figure, montage(permute(D,[1 2 4 3]),'DisplayRange',[]);

%% �{�����[���f�[�^�̉���
volumeViewer(D);

%% ���ɋP�x�̏��������̂��폜
mriAdjust = D;
lb = 40;  % lower threshold (ignore CSF & air)
mriAdjust(mriAdjust <= lb) = 0;
figure, montage(mriAdjust,'DisplayRange',[]);

%% ���W���ƐڐG���Ă��镔���Ȃǂ̍폜
ub = 140; % upper threshold (ignore skull & other hard tissue)
mriAdjust(mriAdjust >= ub) = 0;
figure, montage(mriAdjust,'DisplayRange',[]);

%% �s�v�Ȕ]�̉��̗̈��؂���
mriAdjust(175:end,:,:)  = 0;
figure, montage(mriAdjust,'DisplayRange',[]);

%% �Q�l��
bw    = mriAdjust > 0;
figure, montage(bw,'DisplayRange',[]);

%% �I�[�v�������ł���̈�ȉ��̕������폜
nhood = ones([7 7 3]);
bw = imopen(bw,nhood);
figure, montage(bw,'DisplayRange',[]);

%% �]�̕����̃Z�O�����e�[�V�������s���܂�
% regionprops�Œ��S�_�Ɩʐς��m�F���܂�
L       = bwlabeln(bw);
stats   = regionprops('table',L,'Area')

%% �ł��ʐς��傫��������I��
A       = stats.Area;
biggest = find(A == max(A));
mriAdjust(L ~= biggest) = 0;
figure, montage(mriAdjust,'DisplayRange',[]);

%% �R���g���X�g����
%mriAdjust = imadjust(mriAdjust(:, :, 30));
%figure, montage(mriAdjust,'DisplayRange',[]);

%% �]�̕����̂ݒ��o���āA�\��
level = 65;
mriBrainPartition = uint8(zeros(size(mriAdjust)));    %0=outside brain (head/air)
mriBrainPartition(mriAdjust<level & mriAdjust>0) = 2; %2=gray matter
mriBrainPartition(mriAdjust>=level) = 3;              %3=white matter
figure,imshow(mriBrainPartition(:,:,10),[])

%% �]�����݂̂�3�����\��
Ds = imresize(mriBrainPartition,0.25,'nearest');

% �f�[�^�̌������C��
Ds = flip(Ds,1);
Ds = flip(Ds,2);
Ds = squeeze(Ds);
Ds = permute(Ds,[3 2 1]);

% �{�N�Z���̃X�P�[�����O
voxel_size2 = [1 2 1]; %voxel_size([1 3 2]).*[4 1 4];

%���������ƃO���[�̕����̃T�[�t�F�X���쐬
white_vol = isosurface(Ds,2.5);
gray_vol  = isosurface(Ds,1.5);

% ����
h = figure('visible','off','outerposition',[0 0 800 600],'renderer','openGL');
patch(white_vol,'FaceColor','b','EdgeColor','none');
patch(gray_vol,'FaceColor','y' ,'EdgeColor','none',...
  'FaceAlpha',0.5);
view(45,15); daspect(1./voxel_size2); axis tight;axis off;
camlight; camlight(-80,-10); lighting phong;
movegui(h, 'center');
set(h,'visible','on');

%% �̐όv�Z
stats2 = regionprops3(Ds,'Volume');
Volsize = sum(stats2.Volume)

%% �{�����[���r���[���[�Ŋm�F
volshow(Ds,'ScaleFactors',[1 2 1]);shg

%% �I��

%%
% Copyright 2018-2020 The MathWorks, Inc.