%% �n�C�p�[�X�y�N�g���摜�̑��ݗʃ}�b�v
clc;clear;close all;imtool close all;rng('default');

%% �摜�̓Ǎ���
load('paviaU.mat');
image = paviaU;
sig = signatures;

% �o���h�̐ݒ�
wavelengthRange = [430 860];
numBands = 103;
wavelength = linspace(wavelengthRange(1),wavelengthRange(2),numBands);
% hcube�I�u�W�F�N�g�ɕϊ��E�\��
hcube = hypercube(image,wavelength);
rgbImg = colorize(hcube,'Method','RGB','ContrastStretching',true);
figure
imshow(rgbImg)

%% �G���h�����o�[���̓���
num = 1:size(sig,2);
endmemberCol = num2str(num');
classNames = {'Asphalt';'Meadows';'Gravel';'Trees';'Painted metal sheets';'Bare soil';...
              'Bitumen';'Self blocking bricks';'Shadows'};
table(endmemberCol,classNames,'VariableName',{'Column of sig';'Endmember Class Name'})

figure
plot(sig)
xlabel('Band Number')
ylabel('Data Values')
ylim([400 2700])
title('Endmember Signatures')
legend(classNames,'Location','NorthWest')

%% ���ݗʃ}�b�v�̌v�Z
abundanceMap = estimateAbundanceLS(hcube,sig,'Method','fcls');

fig = figure('Position',[0 0 1100 900]);
n = ceil(sqrt(size(abundanceMap,3)));
for cnt = 1:size(abundanceMap,3)
    subplot(n,n,cnt)
    imagesc(abundanceMap(:,:,cnt))
    title(['Abundance of ' classNames{cnt}])
    hold on
end
hold off

%% Copyright 2020 The MathWorks, Inc.