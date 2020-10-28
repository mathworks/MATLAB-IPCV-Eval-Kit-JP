%% DICOM-RT読み込みと可視化

%% DICOM-RTの読み込み
info = dicominfo('rtstruct.dcm')

%% ROI情報を抽出
contour = dicomContours(info)

%% 可視化
plotContour(contour);

%% マスクの作成
% 空間座標の定義(マスクの範囲を決めるため)
referenceInfo = imref3d([128,128,50],xlim,ylim,zlim);
contourIndex = 1;
rtMask = createMask(rtContours, contourIndex, referenceInfo);
% マスクの表示
volshow(rtMask);

%% 終了
% Copyright 2020 The MathWorks, Inc.