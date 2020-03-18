%% 大規模画像の対話的な観察

%% bigimageオブジェクトの生成
bim = bigimage('tumor_091R.tif');
%% 全体を表示
% 表示される解像度のレベルは、画像サイズによって自動調整される
hf = figure;
haOView = subplot(1,2,1);
haOView.Tag = 'OverView';
hl = bigimageshow(bim,'Parent',haOView);
% 表示レベルを最低解像度に設定
hl.ResolutionLevel = bim.CoarsestResolutionLevel;
title('Overview');
%% 右側に高解像度画像を表示する
haDetailView = subplot(1,2,2);
haDetailView.Tag = 'DetailView';
% ひとまず表示する
hr = bigimageshow(bim,'Parent',haDetailView);
% ズームする
xlim([2350,2600])
ylim([500,750])
title('Detailed View');
%% 表示範囲を指定するための、対話的なROIを設定する
% ズーム範囲に合わせて、ROI窓オブジェクトを作成する
xrange = xlim;
yrange = ylim;
roiPosition = [xrange(1) yrange(1) xrange(2)-xrange(1) yrange(2)-yrange(1)];
hrOView = drawrectangle(haOView,'Position',roiPosition,'Color','r');
%% 右側に表示した画像のハンドルと、左側に作成したROI窓のハンドルを、お互いに呼び出せるようリンクさせる
hrOView.UserData.haDetailView = haDetailView;
haDetailView.UserData.hrOView = hrOView;
%% ユーザの操作をキャッチするリスナーを設定する
% 右側の画像に対しての操作をキャッチ
addlistener(haDetailView,'XLim','PostSet',@updateOverviewROI);
addlistener(haDetailView,'YLim','PostSet',@updateOverviewROI);
% ROI窓に対しての操作をキャッチ
addlistener(hrOView,'MovingROI',@updateDetailView);

%% コールバック関数
function updateOverviewROI(~,hEvt)
  % 右側の画像でズーム/パンをした際に、更新する
  ha = hEvt.AffectedObject;
  hr = hEvt.AffectedObject.UserData.hrOView;
  hr.Position = [ha.XLim(1), ha.YLim(1), diff(ha.XLim), diff(ha.YLim)];
end

function updateDetailView(hSrc,hEvt)
  % 左側に表示されているROI窓を操作した際に、右側の画像を更新する。
  % bigimageshowは自動的に適切な解像度のレベルを選ぶ。
  ha = hSrc.UserData.haDetailView;
  ha.XLim = [hEvt.CurrentPosition(1), ...
      hEvt.CurrentPosition(1)+hEvt.CurrentPosition(3)];
  ha.YLim = [hEvt.CurrentPosition(2), ...
      hEvt.CurrentPosition(2)+hEvt.CurrentPosition(4)];
end
%%
% Copyright 2019 The MathWorks, Inc.

