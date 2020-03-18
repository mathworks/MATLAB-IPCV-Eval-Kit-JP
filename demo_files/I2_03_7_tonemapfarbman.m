%% HDR画像を読み込む
HDR = hdrread('office.hdr');

%% トーンマッピングを実行
LDR = tonemapfarbman(HDR);

%% 並べて可視化
figure,montage({HDR,LDR});

% Copyright 2018 The MathWorks, Inc.