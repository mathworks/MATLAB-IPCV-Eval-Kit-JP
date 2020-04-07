%% DICOM-RT読み込みと可視化

%% DICOM-RTの読み込み
info = dicominfo('rtstruct.dcm')

%% ROI情報を抽出
contour = dicomContours(info)

%% 可視化
plotContour(contour);

%% 終了

%%
% Copyright 2020 The MathWorks, Inc.