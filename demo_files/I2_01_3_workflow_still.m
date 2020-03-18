clear all;clc;close all;imtool close all

%% 静止画　画像処理・解析のワークフロー %%%%%%%%%%%%%%
% 静止画像の読込み
A=imread('peppers.png');
%
% ここに各種画像処理･解析 のコードを挿入 －－－－－－－－－
%
%% 解析結果の挿入(例：玉ねぎを四角で囲む)
loc = [187 75 82 63];     % 例：座標が解析により得られたとした例
A1 = insertShape(A, 'Rectangle', loc, 'Color', 'cyan', 'LineWidth', 3);
%% 静止画像の表示
figure; imshow(A1);       % Figureを一つ開き、画像を表示
%% 結果の書き出し
imwrite(A1, 'tmp_result.png');

%%



% Copyright 2014 The MathWorks, Inc.
