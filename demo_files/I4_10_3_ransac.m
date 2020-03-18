%% RANSAC(MSAC)によるノイズデータへの多項式フィッティング

%% 初期化
clear; close all; clc; rng('default');

%% 放物曲線(2次関数)の式から点を生成
x = (-10:0.1:10)';
y = (36-x.^2)/9;
figure
plot(x,y)
title('放物曲線(2次関数)')

%% 外れ値としてノイズを付加
y = y+rand(length(y),1);
y([50,150,99,199]) = [y(50)+12,y(150)-12,y(99)+33,y(199)-23];
plot(x,y)
title('放物曲線(2次関数)に外れ値としてノイズ付加')
shg;

%% RANSAC(MSAC)による多項式フィッティング
N = 2;           % 2次曲線
maxDistance = 1; % inlier(外れ値でない)とみなす最大距離

% 2次曲線にフィッティング
[P, inlierIdx] = fitPolynomialRANSAC([x,y],N,maxDistance);
disp('2次関数の係数(y=ax^2+bx+c)');
disp(P);

%% フィッティング結果の可視化
yRecoveredCurve = polyval(P,x);
figure
plot(x,yRecoveredCurve,'-g','LineWidth',3)
hold on
plot(x(inlierIdx),y(inlierIdx),'.',x(~inlierIdx),y(~inlierIdx),'ro')
legend('曲線','Inlier点','Outlier点(外れ値)')
hold off

%% 任意の数式モデルへのフィッティング

%% フィッティング対象の外れ値を含む点群をロード
load pointsForLineFitting.mat
plot(points(:,1),points(:,2),'o');
hold on
shg;

%% 最小二乗法でフィッティング
% 外れ値に引っ張られてうまくフィッティングできない
modelLeastSquares = polyfit(points(:,1),points(:,2),1);
x = [min(points(:,1)) max(points(:,1))];
y = modelLeastSquares(1)*x + modelLeastSquares(2);
plot(x,y,'r-')
shg;

%% RANSAC(MSAC)のフィッティング関数と評価関数を設定
fitLineFcn = @(points) polyfit(points(:,1),points(:,2),1); % plyfitをフィッティング関数にする
evalLineFcn = ...   % 曲線と点の距離を計算する関数
  @(model, points) sum((points(:, 2) - polyval(model, points(:,1))).^2,2);

%% RANSACでフィッティング
sampleSize = 2; % RANSACの1ループでサンプリングする点数
maxDistance = 2; % inlier(外れ値でない)とみなすモデルからの距離
[modelRANSAC, inlierIdx] = ransac(points,fitLineFcn,evalLineFcn, ...
  sampleSize,maxDistance);
modelRANSAC

%% inlinerの点だけを使って再度、plyfitで最小二乗フィッティング
modelInliers = polyfit(points(inlierIdx,1),points(inlierIdx,2),1);

%% 結果の可視化
inlierPts = points(inlierIdx,:);
x = [min(inlierPts(:,1)) max(inlierPts(:,1))];
y = modelInliers(1)*x + modelInliers(2);
plot(x, y, 'g-')
legend('外れ値を含む観測点','最小二乗フィッティング','RANSACによるロバストフィッティング');
hold off
shg;

%% 
% Copyright 2018 The MathWorks, Inc.
