%% ハイ ダイナミック レンジ イメージの取扱い

clear;clc;close all;imtool close all

%% ハイ ダイナミック レンジ イメージの読込み
hdr_image = hdrread('office.hdr');   % m x n x 3 single

max(hdr_image(:))
min(hdr_image(:))

imtool(hdr_image);      % 1.0 以上は飽和

hdr_image(66,637,3)     % 3.2813
hdr_image(66,634,:)     % 0.4492, 0.5898, 0.7656

%% トーンマッピング (uint8へ)
rgb = tonemap(hdr_image);

%% 結果の表示
figure;imshow(rgb);

rgb(66,637,3)          % 最大値は255へマッピングされています


%% 一連のローダイナミックレンジ画像ファイルを使った例
files = {'office_1.jpg', 'office_2.jpg', 'office_3.jpg', ...
         'office_4.jpg', 'office_5.jpg', 'office_6.jpg'};
       
% 各画像の相対露光値
expTimes = [0.0333, 0.1000, 0.3333, 0.6250, 1.3000, 4.0000];

% 最も明るいイメージと最も暗いイメージ間の中間の露光値を、
% ハイ ダイナミック レンジの計算に対して、基本露光として使用
hdr = makehdr(files, 'RelativeExposure', expTimes );
hdr1 = makehdr(files, 'RelativeExposure', expTimes ./ expTimes(1));

imtool(hdr,[0 5])
D = imabsdiff(hdr,hdr1);
imtool(D)


rgb = tonemap(hdr);
rgb1 = tonemap(hdr1);

figure; imshow(rgb)
figure; imshow(rgb1)

D = imabsdiff(rgb,rgb1);
imtool(D)

% Copyright 2014 The MathWorks, Inc.
