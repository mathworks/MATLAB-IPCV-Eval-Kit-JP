clear; close all; clc;

%% 画像の読込み・表示
I = imread('visionteam1.jpg');
figure;imshow(I);

%% 人の検出 : ACFアルゴリズム
detector = peopleDetectorACF;
[bboxes, scores] = detect(detector, I)

%% 結果の表示
I1 = insertObjectAnnotation(I, 'rectangle', bboxes, scores, 'FontSize',16, 'LineWidth',3);
figure, imshow(I1);
title('Detected people and detection scores');

%% 終了












%% 人の検出：HOG特徴量 を使う場合
peopleDetector = vision.PeopleDetector;
[bboxes, scores] = step(peopleDetector, I)


%% Copyright 2014 The MathWorks, Inc.
