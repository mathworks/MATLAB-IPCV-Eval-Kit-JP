%% ハイパースペクトル画像の存在量マップ
clc;clear;close all;imtool close all;rng('default');

%% 画像の読込み
load('paviaU.mat');
image = paviaU;
sig = signatures;

% バンドの設定
wavelengthRange = [430 860];
numBands = 103;
wavelength = linspace(wavelengthRange(1),wavelengthRange(2),numBands);
% hcubeオブジェクトに変換・表示
hcube = hypercube(image,wavelength);
rgbImg = colorize(hcube,'Method','RGB','ContrastStretching',true);
figure
imshow(rgbImg)

%% エンドメンバー情報の入力
num = 1:size(sig,2);
endmemberCol = num2str(num');
classNames = {'Asphalt';'Meadows';'Gravel';'Trees';'Painted metal sheets';'Bare soil';...
              'Bitumen';'Self blocking bricks';'Shadows'};
table(endmemberCol,classNames,'VariableName',{'Column of sig';'Endmember Class Name'})

figure
plot(sig)
xlabel('Band Number')
ylabel('Data Values')
ylim([400 2700])
title('Endmember Signatures')
legend(classNames,'Location','NorthWest')

%% 存在量マップの計算
abundanceMap = estimateAbundanceLS(hcube,sig,'Method','fcls');

fig = figure('Position',[0 0 1100 900]);
n = ceil(sqrt(size(abundanceMap,3)));
for cnt = 1:size(abundanceMap,3)
    subplot(n,n,cnt)
    imagesc(abundanceMap(:,:,cnt))
    title(['Abundance of ' classNames{cnt}])
    hold on
end
hold off

%% Copyright 2020 The MathWorks, Inc.