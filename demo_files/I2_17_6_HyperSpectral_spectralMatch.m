%% �n�C�p�[�X�y�N�g���摜�̃X�y�N�g���}�b�`���O
clc;clear;close all;imtool close all;rng('default');

%% �X�y�N�g�����C�u��������̐A���V�O�l�`���̒��o
fileroot = matlabshared.supportpkg.getSupportPackageRoot();
filename = fullfile(fileroot,'toolbox','images','supportpackages','hyperspectral','hyperdata',...
               'ECOSTRESSSpectraFiles','vegetation.tree.tsuga.canadensis.vswir.tsca-1-47.ucsb.asd.spectrum.txt');
libData = readEcostressSig(filename);

%% �n�C�p�[�X�y�N�g���f�[�^�̓ǂݍ���
hcube = hypercube('paviaU.hdr');

%% �X�y�N�g���}�b�`���O
% �摜�S�̂���A���̃V�O�l�`���ɑ΂��鋗�����v�Z
score = spectralMatch(libData, hcube);

figure
imagesc(score)
colorbar

%% �A���}�X�N�𐶐�
% �A���ƍl������̈�̒��o
threshold = 0.3;
bw = score < threshold;
% �}�X�N
Ts = hcube.DataCube .* double(bw);
segmentedDatacube = hypercube(Ts, hcube.Wavelength);

% ����
rgbImg = colorize(hcube,'Method','rgb','ContrastStretching',true);
segmentedImg = colorize(segmentedDatacube,'Method','rgb','ContrastStretching',true);
B = imoverlay(rgbImg, bw,'Yellow');

figure;
montage({rgbImg segmentedImg B },'Size', [1 3]);
title(['Original Image | ' 'Segmented Image | ' 'Overlayed Image']);

%% Copyright 2020 The MathWorks, Inc.
