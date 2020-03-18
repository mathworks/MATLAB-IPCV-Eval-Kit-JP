%% カメラ応答関数(CRF)を推定

%% 6つのLDR(Low Dynamic Range)画像を準備(F値が同じで露光時間だけが異なる)
files = ["office_1.jpg","office_2.jpg","office_3.jpg",...
         "office_4.jpg","office_5.jpg","office_6.jpg"];

%% カメラ応答関数を推定
crf = camresponse(files);

%% 入力画像の輝度レベルを指定
range = 0:length(crf)-1;

%% RGBそれぞれの成分でのカメラ応答関数をプロット
figure,
hold on
plot(crf(:,1),range,'--r','LineWidth',2);
plot(crf(:,2),range,'-.g','LineWidth',2);
plot(crf(:,3),range,'-.b','LineWidth',2);
xlabel('Log-Exposure');
ylabel('Image Intensity');
title('Camera Response Function');
grid on
axis('tight')
legend('R-component','G-component','B-component','Location','southeast')

% Copyright 2019 The MathWorks, Inc.