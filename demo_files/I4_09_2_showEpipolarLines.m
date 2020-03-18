clear;clc;close all;imtool close all

%% 予め求めてある左右の画面上の点をLoad
load stereoPointPairs

%% 予め求めてある左右の画面上の点から、基礎行列を推定
[fLMedS, inliers] = estimateFundamentalMatrix(matchedPoints1,matchedPoints2,'NumTrials',4000);

%% 左の画像上に、inlier の点を表示
I1 = imread('viprectification_deskLeft.png');
figure; 
subplot(1,2,1); imshow(I1); title('Inliers and Epipolar Lines in First Image'); hold on;
plot(matchedPoints1(inliers,1), matchedPoints1(inliers,2), 'go')

%% Show the inliers in the second image.
I2 = imread('viprectification_deskRight.png');
subplot(122); imshow(I2); title('Inliers and Epipole Lines in Second Image'); hold on;
plot(matchedPoints2(inliers,1), matchedPoints2(inliers,2), 'go')

%% 右側のマッチ点に対する、左画面上のエピポーラ線
epiLines = epipolarLine(fLMedS', matchedPoints2(inliers, :));

%% Compute the intersection points of the lines and the image border.
pts = lineToBorderPoints(epiLines, size(I1));

%% Show the epipolar lines in the first image
line(pts(:, [1,3])', pts(:, [2,4])');




%% Compute and show the epipolar lines in the second image.
epiLines = epipolarLine(fLMedS, matchedPoints1(inliers, :));
pts = lineToBorderPoints(epiLines, size(I2));
line(pts(:, [1,3])', pts(:, [2,4])');
truesize;

%%
%  Copyright 2014 The MathWorks, Inc.
