%% ハフ変換 デモ
clear;clc;close all;imtool close all

%% 孤立点の生成
BW = false(40);
BW(20,15)=1;
figure;imshow(BW);

%% 孤立点に対するHough変換・表示
%      H:     ハフ変換行列
%      theta: x軸値 : 角度(°)   -90°～89°  正のX軸に対して時計回りに定義
%      rho  : y軸値 : 原点からの距離
[H,theta,rho] = hough(BW);
figure, imshow(imadjust(mat2gray(H)),[],'XData',theta,'YData',rho,...
        'InitialMagnification','fit');
xlabel('\theta (degrees)'), ylabel('\rho');
axis on; axis normal         % 座標表示
colormap(hot)

%% 3点に対するHough変換･表示
BW(22,17)=1;
BW(24,19)=1;
figure;imshow(BW);

%% Hough変換・表示
%      H:     ハフ変換行列
%      theta: x軸値 : 角度(°)   -90°～89°  正のX軸に対して時計回りに定義
%      rho  : y軸値
[H,theta,rho] = hough(BW);
figure, imshow(imadjust(mat2gray(H)),[],'XData',theta,'YData',rho,...
        'InitialMagnification','fit');
xlabel('\theta (degrees)'), ylabel('\rho');
axis on; axis normal         % 座標表示
colormap(hot)

%% 関数 houghpeaks を使ってハフ変換行列 H 内のピーク点を検出・プロット
peak = houghpeaks(H)
hold on
   % ピークのthetaとrho値を取得して四角をPlot
plot(theta(peak(:,2)), rho(peak(:,1)), 's','color','red','MarkerFaceColor','red');
hold off

%% 関数 houghlines を使ってイメージ内の線を検出。
%    lines： point1, point2, theta, rho
%    同一直線上で、線分間の距離が指定値(5)よりも小さい場合2つの線分を１つに結合
lines = houghlines(BW, theta, rho, peak, 'FillGap', 5, 'MinLength', 3);
% 元のイメージに重ねて線をプロットします。
xy = [reshape([lines.point1],2,[]); reshape([lines.point2],2,[])]';
BW1 = insertShape(uint8(BW), 'line', xy,'SmoothEdges',false);
imtool(BW1);

[lines.rho]          % 原点から直線までの距離
[lines.theta]        % 垂線の角度 (°)



%% LSIの写真の解析 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;clc;close all;imtool close all            % 初期化

I  = imread('circuit.tif');
rotI = imrotate(I,33,'crop');
figure; imshow(rotI);

%% エッジ検出
BW = edge(rotI,'canny');
figure, imshow(BW);

%% Hough変換・表示
%      H:     ハフ変換行列
%      theta: x軸値 : 角度(°)   -90°～89°  正のX軸に対して時計回りに定義
%      rho  : y軸値
[H,theta,rho] = hough(BW);

figure, imshow(imadjust(mat2gray(H)),[],'XData',theta,'YData',rho,...
        'InitialMagnification','fit');
xlabel('\theta (degrees)'), ylabel('\rho');
axis on; axis normal         % 座標表示
colormap(hot)

%% 関数 houghpeaks を使ってハフ変換行列 H 内のピーク点を検出(5個)・プロット
%    最大値の0.3に満たないものはピークとしない
%    ピークの点のthetaとrhoの番号組(線分が切れている可能性 => 5つとは限らない)
hold on
peak = houghpeaks(H, 5, 'threshold', ceil(0.3*max(H(:))));
plot(theta(peak(:,2)), rho(peak(:,1)), 's','color','black','MarkerFaceColor','green');   % thetaとrhoの番号から値を取得して四角をPlot
hold off

%% 関数 houghlines を使ってイメージ内の線を検出します。
%    lines： point1, point2, theta, rho
%    同一直線上で、線分間の距離が指定値(5)よりも小さい場合2つの線分を１つに結合
lines = houghlines(BW, theta, rho, peak, 'FillGap', 5, 'MinLength', 7);

% 元のイメージに重ねて線をプロットします。
figure, imshow(rotI), hold on
for k = 1:length(lines)
   %   xy : [x1 y1; x2 y2]
   xy = [lines(k).point1; lines(k).point2];
   plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
end
[lines.theta]
hold off

%% 終了






% 
% 
%    % 始点終点にマーク必要なとき：for内に以下を入れる
%    plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
%    plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
% 
%    % 一番長い線を赤く表示必要なとき
%     %forの前に
%          max_len = 0;
%    % 下記をfor内
%          len = norm(lines(k).point1 - lines(k).point2);
%          if ( len > max_len)
%            max_len = len;
%            xy_long = xy;
%          end
%   %  for の後に
%          % 一番長い線を、赤で表示
%          plot(xy_long(:,1),xy_long(:,2),'LineWidth',2,'Color','red');
   
   


%% LSIの写真の解析 (大きい画像：関数で処理した場合)%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;clc;close all;imtool close all            % 初期化

I  = imread('circuit.tif');
rotI = imrotate(I,33,'crop');
figure; imshow(rotI);

%% エッジ検出
BW = edge(rotI,'canny');
BW = imresize(BW,10,'bicubic');
figure, imshow(BW);

%% Hough変換・表示 %%%%%%%%%%%%%%
%      H:     ハフ変換行列
%      theta: x軸値 : 角度(°)   -90°～89°  正のX軸に対して時計回りに定義
%      rho  : y軸値
[H,theta,rho] = hough(BW);

figure, imshow(imadjust(mat2gray(H)),[],'XData',theta,'YData',rho,...
        'InitialMagnification','fit');
xlabel('\theta (degrees)'), ylabel('\rho');
axis on; axis normal         % 座標表示
colormap(hot)

%% 関数 houghpeaks を使ってハフ変換行列 H 内のピーク点を検出(5個)・プロット
%    最大値の0.3に満たないものはピークとしない
%    ピークの点のthetaとrhoの番号組(線分が切れている可能性 => 5つとは限らない)
hold on
peak = houghpeaks(H, 5, 'threshold', ceil(0.3*max(H(:))));
plot(theta(peak(:,2)), rho(peak(:,1)), 's','color','black','MarkerFaceColor','green');   % thetaとrhoの番号から値を取得して四角をPlot
hold off

%% 関数 houghlines を使ってイメージ内の線を検出します。
%    lines： point1, point2, theta, rho
%    同一直線上で、線分間の距離が指定値(5)よりも小さい場合2つの線分を１つに結合
lines = houghlines(BW, theta, rho, peak, 'FillGap', 5, 'MinLength', 7);

% 元のイメージに重ねて線をプロットします。
figure, imshow(BW), hold on
for k = 1:length(lines)
   %   xy : [x1 y1; x2 y2]
   xy = [lines(k).point1; lines(k).point2];
   plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
end
[lines.theta]
hold off

%% 終了

% Copyright 2014 The MathWorks, Inc.