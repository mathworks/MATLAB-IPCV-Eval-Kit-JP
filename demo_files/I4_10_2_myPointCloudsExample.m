%% 3�����_�Q�� �\���E�ʒu���킹�E����
clc;clear;close all;imtool close all;

%% unorganized 3�����_�Q��PLY�`���̃f�[�^�̓ǂݍ��݁ipointCloud �N���X�j%%%%%%%%
ptCloud = pcread('teapot.ply')   % 41472��x,y,z�̑g�F�R�}���h �E�B���h�E�Q��

%% ��j1�Ԗڂ̓_�́Ax,y,z���W
ptCloud.Location(1,:)

%% �\�� (�F�f�[�^���Ȃ��̂ŁAZ�������ɃO���f�[�V�����F�\��)
figure; pcshow(ptCloud);
xlabel('X'); ylabel('Y'); zlabel('Z'); box on

%% �ʂ̃f�[�^�Z�b�g�Funorganized��3�����_�Q�̏���
% �_�Q�f�[�^�̓ǂݍ���
load('object3d.mat')

%% �_�Q�̕\��
figure
pcshow(ptCloud)
xlabel('X(m)')
ylabel('Y(m)')
zlabel('Z(m)')
title('Original Point Cloud')

%% �e�[�u���̌��o(���ʃt�B�b�e�B���O)
% ���ʃt�B�b�e�B���O�̃p�����[�^�̐ݒ�
maxDistance = 0.02;
referenceVector = [0,0,1];
maxAngularDistance = 5;
[model1,inlierIndices,outlierIndices] = pcfitplane(ptCloud,...
            maxDistance,referenceVector,maxAngularDistance);
plane1 = select(ptCloud,inlierIndices);
remainPtCloud = select(ptCloud,outlierIndices);
figure
pcshow(plane1)
title('�ŏ��̕���')

%% ���̕ǖʂ̌��o(���ʃt�B�b�e�B���O)
roi = [-inf,inf;0.4,inf;-inf,inf];
sampleIndices = findPointsInROI(remainPtCloud,roi);
[model2,inlierIndices,outlierIndices] = pcfitplane(remainPtCloud,...
            maxDistance,'SampleIndices',sampleIndices);
plane2 = select(remainPtCloud,inlierIndices);
remainPtCloud = select(remainPtCloud,outlierIndices);
figure
pcshow(plane2)
title('2�Ԗڂ̕���')

%% ���̕ǖʂ̌��o(���ʃt�B�b�e�B���O)
roi = [-inf,inf;-inf,inf;-inf,inf];
sampleIndices = findPointsInROI(remainPtCloud,roi);
[model3,inlierIndices,outlierIndices] = pcfitplane(remainPtCloud,...
            maxDistance,'SampleIndices',sampleIndices);
plane3 = select(remainPtCloud,inlierIndices);
remainPtCloud = select(remainPtCloud,outlierIndices);
figure
pcshow(plane3)
title('3�Ԗڂ̕���')

%% �c��̓_�Q�̕\��
figure
axPc = pcshow(remainPtCloud);
axis([ptCloud.XLimits, ptCloud.YLimits, ptCloud.ZLimits]);
hold on;
plot(model1,'Color','yellow');
alpha(0.5);
plot(model2,'Color','magenta');
alpha(0.5);
plot(model3,'Color','cyan');
alpha(0.5);
title('�c��̓_�Q��\��')

%% �_�Q�̃Z�O�����e�[�V����
distThreshold = 0.1;
[labels,numClusters] = pcsegdist(remainPtCloud,distThreshold);
cmap = lines(numClusters);
for k = 1:numClusters
    pc = select(remainPtCloud,find(labels==k));
    I4_10_2_plot3DBBox(pc,cmap(k,:),gca);
end
title('�_�Q�̃Z�O�����e�[�V����(�N���X�^�����O)')
shg;

%% �ʂ̃f�[�^�Z�b�g�Forganized 3�����_�Q�f�[�^�̓Ǎ��� %%%%%%%%%%%%%%%%%%%%%%%%%
%    livingRoomData: 44����PointCloud�f�[�^�i�e�_��world���W�l�ƁA�F�����j
load('livingRoom.mat');

%% 1���ڂ̃f�[�^�𒊏o
ptCloudRef = livingRoomData{1}   %1�Ԗڂ̃f�[�^�����t�@�����XPointCloud�Ƃ���

%% ��j(100,100)�� x,y,z���W
ptCloudRef.Location(100, 100, :)

%% �F�f�[�^(�J���[�摜)��\��
figure; imshow(ptCloudRef.Color); title('1st');

%% 3�����_�Q�f�[�^��\��
figure; pcshow(ptCloudRef, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down', 'MarkerSize',18);
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)'); title('1st'); view(0,-90); box on;

%% 2�Ԗڂ̃f�[�^�𒊏o�E���ׂĕ\��
ptCloudCurrent = livingRoomData{2};
% �\��
subplot(1,2,1);pcshow(ptCloudRef, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down', 'MarkerSize',18);
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)'); title('1st'); view(0,-90);box on
subplot(1,2,2);pcshow(ptCloudCurrent, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down', 'MarkerSize',18);
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)'); title('2nd'); view(0,-90);box on; shg;

%% 2�̓_�Q�f�[�^���d�˂ĕ\��
figure; pcshowpair(ptCloudRef, ptCloudCurrent, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down');
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)'); box on

%% [�O����] PointCloud�̃f�[�^�_���Ԉ����i�I���W�i����307,200�f�[�^�_ => ��1500�f�[�^�_�ցj
%    ������(box grid)���̑S�_�̍��W�𕽋ς���1�̓_�ɏW��
%    �ʒu���킹�̑��x�Ȃ�тɐ��x�̉��P�ipcdenoise�̎g�p�̓I�v�V���i���j
gridSize = 0.1;   % 10cm�p�@�i�_�Q�f�[�^��X,Y,Z�l�̒P�ʂ�m�j
fixed = pcdownsample(ptCloudRef, 'gridAverage', gridSize);
moving = pcdownsample(ptCloudCurrent, 'gridAverage', gridSize);

% �\��
figure;
subplot(1,2,1);pcshow(fixed, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down', 'MarkerSize',18);
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)'); title('1st'); view(0,-90);box on
subplot(1,2,2);pcshow(moving, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down', 'MarkerSize',18);
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)'); title('2nd'); view(0,-90);box on; shg;

%% ICP(iterative closest point) algorithm�ɂ�郌�W�X�g���[�V����
% ���W�X�g���[�V�����i2�̓_�Q�Ԃ̕ϊ��s��𐄒�j
tformICP = pcregistericp(moving, fixed, 'Metric','pointToPlane','Extrapolate', true)
tformICP.T     % �ϊ�(�ˉe)�s����m�F

% (�Ԉ����Ȃ��̃f�[�^�ɑ΂�) �􉽊w�I�ϊ����A2�Ԗڂ̓_�Q���A1�Ԗڂ̓_�Q�̍��W�֕ϊ���\��
ptCloudAlignedICP = pctransform(ptCloudCurrent, tformICP);

%�\��
subplot(3,2,1);pcshow(ptCloudRef, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down', 'MarkerSize',18);
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)'); title('1st'); view(0,-90); box on;
subplot(3,2,2);pcshow(ptCloudCurrent, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down', 'MarkerSize',18);
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)'); title('2nd'); view(0,-90); box on;
subplot(3,2,3);pcshow(ptCloudAlignedICP, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down', 'MarkerSize',18);
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)'); title('2nd (Aligned with ICP)'); view(0,-90); box on; shg;

%% NDT(normal-distributions transform) algorithm�ɂ�郌�W�X�g���[�V����
% ���W�X�g���[�V�����i2�̓_�Q�Ԃ̕ϊ��s��𐄒�j
gridStep = 0.5;
tformNDT = pcregisterndt(moving,fixed,gridStep)
tformNDT.T     % �ϊ�(�ˉe)�s����m�F

% (�Ԉ����Ȃ��̃f�[�^�ɑ΂�) �􉽊w�I�ϊ����A2�Ԗڂ̓_�Q���A1�Ԗڂ̓_�Q�̍��W�֕ϊ���\��
ptCloudAlignedNDT = pctransform(ptCloudCurrent, tformNDT);

%�\��
subplot(3,2,4);pcshow(ptCloudAlignedNDT, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down', 'MarkerSize',18);
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)'); title('2nd (Aligned with NDT)'); view(0,-90); box on; shg;

%% CPD(coherent point drift)�A���S���Y���ɂ��񍄑̓_�Q���W�X�g���[�V����
% 2�̓_�Q�Ԃ̑Ή��֌W����K�p��̊e�_�Q��displacement�𐄒�
tformCPD = pcregistercpd(moving,fixed);

% 2�Ԗڂ̓_�Q���A1�Ԗڂ̓_�Q�̍��W�֕ϊ�
% (�􉽊w�ϊ��s��̐���ł͂Ȃ��A
% �_�Q�Ԃ�displacement���v�Z���Ă��邽�߃_�E���T���v���������̂ɓK�p)
ptCloudAlignedCPD = pctransform(moving, tformCPD);

%�\��
subplot(3,2,5);pcshow(ptCloudAlignedCPD, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down', 'MarkerSize',18);
%figure; pcshow(ptCloudAlignedCPD, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down', 'MarkerSize',18);
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)'); title('2nd (Aligned with CPD)'); view(0,-90); box on; shg;

%% �ʑ����葊�֖@(Phase-Only Correlation) algorithm�ɂ�郌�W�X�g���[�V����
% ���W�X�g���[�V�����i2�̓_�Q�Ԃ̕ϊ��s��𐄒�j
gridSizePOC = 100;
gridStepPOC = 0.5;

tformPOC = pcregistercorr(moving,fixed,gridSizePOC,gridStepPOC);
tformPOC.T     % �ϊ�(�ˉe)�s����m�F

% (�Ԉ����Ȃ��̃f�[�^�ɑ΂�) �􉽊w�I�ϊ����A2�Ԗڂ̓_�Q���A1�Ԗڂ̓_�Q�̍��W�֕ϊ���\��
ptCloudAlignedPOC = pctransform(ptCloudCurrent, tformPOC);

%�\��
subplot(3,2,6);pcshow(ptCloudAlignedPOC, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down', 'MarkerSize',18);
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)'); title('2nd (Aligned with POC)'); view(0,-90); box on; shg;

%% 2��3�����_�Q�𓝍���\��
mergeSize = 0.015;   % 1.5cm��box grid filter�ŁA�d���̈���t�B���^�����O�B
                     % box���ɕ����_������ꍇ�A�ʒu�E�F�̕��ς��v�Z
ptCloudSceneICP = pcmerge(ptCloudRef, ptCloudAlignedICP, mergeSize);

% �\��
subplot(1,2,1);pcshow(ptCloudRef, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down', 'MarkerSize',18);
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)'); title('1st'); view(0,-90); box on
subplot(1,2,2);pcshow(ptCloudSceneICP, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down', 'MarkerSize',18);
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)'); title('Stitched (1st+2nd)'); view(0,-90);box on; shg;

%% 3�Ԗڈȍ~�̓_�Q���������Ă���
accumTformICP = tformICP; 

figure;
hAxes = pcshow(ptCloudSceneICP, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down', 'MarkerSize',18);
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)'); box on
% Axes�̃v���p�e�B�[���Z�b�g�i�`��̍������j
hAxes.CameraViewAngleMode = 'auto';
hScatter = hAxes.Children;

for i = 3:44      %length(livingRoomData)
    % ���̃|�C���g�N���E�h�f�[�^��Ǎ���
    ptCloudCurrent = livingRoomData{i};
    % ��O�̃|�C���g�N���E�h�f�[�^�����t�@�����X�Ƃ��Đݒ�
    fixed = moving;
    % �|�C���g�N���E�h�̃f�[�^���Ԉ���
    moving = pcdownsample(ptCloudCurrent, 'gridAverage', gridSize);
    
    % ICP �ʒu���킹��K�p
    tformICP = pcregistericp(moving, fixed, 'Metric','pointToPlane','Extrapolate', true);

    % �ŏ��̉摜�̍��W�n�֕ϊ�
    accumTformICP = affine3d(tformICP.T * accumTformICP.T);
    ptCloudAlignedICP = pctransform(ptCloudCurrent, accumTformICP);
    
    % �_�Q�̌���
    ptCloudSceneICP = pcmerge(ptCloudSceneICP, ptCloudAlignedICP, mergeSize);

    % Visualize the world scene.
    hScatter.XData = ptCloudSceneICP.Location(:,1);
    hScatter.YData = ptCloudSceneICP.Location(:,2);
    hScatter.ZData = ptCloudSceneICP.Location(:,3);
    hScatter.CData = ptCloudSceneICP.Color;
    drawnow limitrate;
end  

%% ���̖ʂ𐄒肷�邽�߂̃p�����[�^���`
maxDistance = 0.01;                 % ���肵���ʂ�inlier�_�̍ő勗�� (1cm)
referenceVector = [0, 5, 1.5];      % �Q�Ɨp �ʂ̖@���x�N�g��
% �Q�Ɨp�̖@���x�N�g���ƁA���肷��ʂ̖@���x�N�g���̋��e�ő�덷�i��Βl�j
maxAngularDistance = 5;
rng('default');

%% �Q�Ɨp�̖@���x�N�g���ɋ߂��ʂ𐄒�
[model1, inlierIndices, outlierIndices] = ...
      pcfitplane(ptCloudSceneICP,maxDistance,referenceVector,maxAngularDistance);
model1        % planeModel �I�u�W�F�N�g: ax+by+cz+d=0 �̌W���A�@���x�N�g��

%% �S3�����_�Q�f�[�^�ɁA���肵���ʂ��d�ˏ���
%figure; pcshow(ptCloudSceneICP, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down', 'MarkerSize',18); hold on;
figure; pcshow(ptCloudSceneICP, 'MarkerSize',18); hold on;

xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)'); box on

h1 = plot(model1); hold off
h1.FaceAlpha = 0.5;

%% ���肵�����ʂ��AXZ���ʂɕ��s�ɂ��饕\��
angle = -1*atan(model1.Normal(3)/model1.Normal(2))
A = [1,           0,          0, 0;...
     0,  cos(angle), sin(angle), 0; ...
     0, -sin(angle), cos(angle), 0; ...
     0,           0,          0, 1];
ptCloudScene1 = pctransform(ptCloudSceneICP, affine3d(A));

figure; pcshow(ptCloudScene1, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down', 'MarkerSize',18)
xlabel('X (m)');ylabel('Y (m)');zlabel('Z (m)'); box on;

%% normalRotation�֐����g�p���ď��ʂ��AXY���ʂɕ��s�ɂ��饕\��
referenceVector = [0 0 -1]; % ���ʂ��Q�ƃx�N�g���ɑ΂������ɂȂ�悤�ɐݒ�
tform = normalRotation(model1,referenceVector); % �Q�ƃx�N�g������ɖʂ̖@���Ƃ̉�]�s����v�Z

ptCloudScene2 = pctransform(ptCloudSceneICP, rigid3d(pinv(tform.T))); % �t��]

figure; pcshow(ptCloudScene2, 'MarkerSize',18)
xlabel('X (m)');ylabel('Y (m)');zlabel('Z (m)'); box on;

%%  �I��





%% ��]�p���s��ւ̕ϊ�
rotationVectorToMatrix([0, 0,  -0.2691])

%% ���肵�����ʏ�̓_�݂̂𒊏o��\��
plane1 = select(ptCloudSceneICP,inlierIndices);
figure;pcshow(plane1, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down', 'MarkerSize',18);
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)'); box on


%% �X�`�b�e�B���O��ICP��NDT�Ŕ�r
% organized 3�����_�Q�f�[�^�̓Ǎ��� %%%%%%%%%%%%%%%%%%%%%%%%%
% livingRoomData: 88����PointCloud�f�[�^�i�e�_��world���W�l�ƁA�F�����j
load('livingRoom.mat');
sz = get(groot,'ScreenSize');
% Stop �{�^���\��
a=true;
figure('MenuBar','none','Toolbar','none','Position',[20 sz(4)-100 100 70]);
uicontrol('Style', 'pushbutton', 'String', 'Stop',...
        'Position', [20 20 80 40], 'Callback', 'a=false;');

figure;
title('Updated world scene');
gridSize = 0.1;   % 10cm�p
mergeSize = 0.015;   % 1.5cm��box grid filter�ŁA�d���̈���t�B���^�����O

while (a)
ptCloudRef = livingRoomData{1};
ptCloudCurrent = livingRoomData{2};
fixed  = pcdownsample(ptCloudRef, 'gridAverage', gridSize);
moving = pcdownsample(ptCloudCurrent, 'gridAverage', gridSize);
tformICP = pcregistericp(moving, fixed, 'Metric','pointToPlane','Extrapolate', true);
tformNDT = pcregisterndt(moving, fixed, 0.5);
ptCloudAlignedICP = pctransform(ptCloudCurrent, tformICP);
ptCloudAlignedNDT = pctransform(ptCloudCurrent, tformNDT);
ptCloudSceneICP = pcmerge(ptCloudRef, ptCloudAlignedICP, mergeSize);
ptCloudSceneNDT = pcmerge(ptCloudRef, ptCloudAlignedNDT, mergeSize);

accumTformICP = tformICP; 
accumTformNDT = tformNDT; 

ax = subplot(1,2,1);
hAxes = pcshow(ptCloudSceneICP, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down', 'MarkerSize',18, 'Parent',ax);
title('ICP');
ax = subplot(1,2,2);
hAxes2 = pcshow(ptCloudSceneNDT, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down', 'MarkerSize',18, 'Parent',ax);
title('NDT');
% Axes�̃v���p�e�B�[���Z�b�g�i�`��̍������j
hAxes.CameraViewAngleMode = 'auto';
hAxes2.CameraViewAngleMode = 'auto';
hScatter = hAxes.Children;
hScatter2 = hAxes2.Children;

for i = 3:44      %length(livingRoomData)
    if (~a)
        break;
    end
    % ���̃|�C���g�N���E�h�f�[�^��Ǎ���
    ptCloudCurrent = livingRoomData{i};
    % ��O�̃|�C���g�N���E�h�f�[�^�����t�@�����X�Ƃ��Đݒ�
    fixed = moving;
    % �|�C���g�N���E�h�̃f�[�^���Ԉ���
    moving = pcdownsample(ptCloudCurrent, 'gridAverage', gridSize);
    
    % ICP �ʒu���킹��K�p
    tformICP = pcregistericp(moving, fixed, 'Metric','pointToPlane','Extrapolate', true);
    tformNDT = pcregisterndt(moving, fixed, 0.5);

    % �ŏ��̉摜�̍��W�n�֕ϊ�
    accumTformICP = affine3d(tformICP.T * accumTformICP.T);
    ptCloudAlignedICP = pctransform(ptCloudCurrent, accumTformICP);
    accumTformNDT = affine3d(tformICP.T * accumTformNDT.T);
    ptCloudAlignedNDT = pctransform(ptCloudCurrent, accumTformNDT);
    
    % �_�Q�̌���
    ptCloudSceneICP = pcmerge(ptCloudSceneICP, ptCloudAlignedICP, mergeSize);
    ptCloudSceneNDT = pcmerge(ptCloudSceneNDT, ptCloudAlignedNDT, mergeSize);

    % Visualize the world scene.
    hScatter.XData = ptCloudSceneICP.Location(:,1);
    hScatter.YData = ptCloudSceneICP.Location(:,2);
    hScatter.ZData = ptCloudSceneICP.Location(:,3);
    hScatter.CData = ptCloudSceneICP.Color;
    hScatter2.XData = ptCloudSceneNDT.Location(:,1);
    hScatter2.YData = ptCloudSceneNDT.Location(:,2);
    hScatter2.ZData = ptCloudSceneNDT.Location(:,3);
    hScatter2.CData = ptCloudSceneNDT.Color;
    drawnow limitrate;
end  

end   %while



%% Copyright 2020 The MathWorks, Inc.

