%% �u���b�N�摜�̑Θb�I�Ȋώ@
%% bigimage�I�u�W�F�N�g�̐���
bim = blockedImage('tumor_091R.tif');
%% �S�̂�\��
% �\�������𑜓x�̃��x���́A�摜�T�C�Y�ɂ���Ď������������
hf = figure;
tiledlayout(1,2,"Padding","compact","TileSpacing","compact");
haOView = nexttile;
haOView.Tag = 'OverView';
hl = bigimageshow(bim,'Parent',haOView);
coarsestLevel = bim.NumLevels;
hl.ResolutionLevel = coarsestLevel;
title('Overview');
%% �E���ɍ��𑜓x�摜��\������
haDetailView = nexttile;
haDetailView.Tag = 'DetailView';
% �ЂƂ܂��\������
hr = bigimageshow(bim,'Parent',haDetailView);
% �Y�[������
xlim([2100,2600])
ylim([500,1000])
title('Detailed View');
%% �\���͈͂��w�肷�邽�߂́A�Θb�I��ROI��ݒ肷��
% �Y�[���͈͂ɍ��킹�āAROI���I�u�W�F�N�g���쐬����
xrange = xlim;
yrange = ylim;
roiPosition = [xrange(1) yrange(1) xrange(2)-xrange(1) yrange(2)-yrange(1)];
hrOView = drawrectangle(haOView,'Position',roiPosition,'Color','r');
%% �E���ɕ\�������摜�̃n���h���ƁA�����ɍ쐬����ROI���̃n���h�����A���݂��ɌĂяo����悤�����N������
hrOView.UserData.haDetailView = haDetailView;
haDetailView.UserData.hrOView = hrOView;
%% ���[�U�̑�����L���b�`���郊�X�i�[��ݒ肷��
% �E���̉摜�ɑ΂��Ă̑�����L���b�`
addlistener(haDetailView,'XLim','PostSet',@updateOverviewROI);
addlistener(haDetailView,'YLim','PostSet',@updateOverviewROI);
% ROI���ɑ΂��Ă̑�����L���b�`
addlistener(hrOView,'MovingROI',@updateDetailView);

%% �R�[���o�b�N�֐�
function updateOverviewROI(~,hEvt)
  % �E���̉摜�ŃY�[��/�p���������ۂɁA�X�V����
  ha = hEvt.AffectedObject;
  hr = hEvt.AffectedObject.UserData.hrOView;
  hr.Position = [ha.XLim(1), ha.YLim(1), diff(ha.XLim), diff(ha.YLim)];
end

function updateDetailView(hSrc,hEvt)
  % �����ɕ\������Ă���ROI���𑀍삵���ۂɁA�E���̉摜���X�V����B
  % bigimageshow�͎����I�ɓK�؂ȉ𑜓x�̃��x����I�ԁB
  ha = hSrc.UserData.haDetailView;
  ha.XLim = [hEvt.CurrentPosition(1), ...
      hEvt.CurrentPosition(1)+hEvt.CurrentPosition(3)];
  ha.YLim = [hEvt.CurrentPosition(2), ...
      hEvt.CurrentPosition(2)+hEvt.CurrentPosition(4)];
end
%%
% Copyright 2021 The MathWorks, Inc.

