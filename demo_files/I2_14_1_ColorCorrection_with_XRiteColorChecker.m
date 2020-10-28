%% X-Riteカラーチェッカーを使った色補正
%% テスト画像の読み込み
I = imread('colorCheckerTestImage.jpg');
%% カラーチェッカーの自動読み取り
chart = colorChecker(I);
% 読み取り結果の表示
displayChart(chart);
%% 色の読み取り
[colorTable,ccm] = measureColor(chart);
figure(2);
tiledlayout(1,2,'Padding','compact');
nexttile;
displayColorPatch(colorTable) % ΔEが1に近いほど色見本との違いは小さい
%% 色補正
I_cc = imapplymatrix(ccm(1:3,:)',I,ccm(4,:));
figure;
imshow([I,I_cc]);
title('色補正前後の比較')

% 補正結果の定量的な確認
chart = colorChecker(I_cc);
[colorTable_cc,ccm] = measureColor(chart);
figure(2);
nexttile;
displayColorPatch(colorTable_cc)
%%
% Copyright 2020 The MathWorks, Inc.