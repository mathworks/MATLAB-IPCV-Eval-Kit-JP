%% テキストの傾きの修正
clc;close all;imtool close all;clear;

%% テスト画像の作成
x = imread('text.png');
I = uint8(x(5:60,5:end-40)*255);
I = imrotate(I, 30, 'bicubic');     % 反時計回りに30度回転
figure; imshow(I);

%% 画像のぼかし 
BW = imdilate(logical(I), strel('disk',4));  
figure; imshow(BW);

%% Hough変換し、角度を求め、逆回転補正
%      H:     ハフ変換行列
%      theta: x軸値 : 角度(°)   -90°～89°  正のX軸に対して時計回りに定義
%      rho  : y軸値
[H,theta,rho] = hough(BW);
peak = houghpeaks(H, 1)        % ピークの点のthetaとrhoの番号組
%% 関数 houghlines を使って検出された線の表示
lines = houghlines(BW, theta, rho, peak);      %lines： point1, point2, theta, rho を持つ構造体
% 元のイメージに重ねて線をプロット
hold on
xy = [lines.point1; lines.point2];   %   xy : [x1 y1; x2 y2]
plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
hold off

%% 逆回転して補正
if theta(peak(1,2)) > 0
    ang = 90 - theta(peak(1,2));
else
    ang = -1 * (90 + theta(peak(1,2)));
end
Irot = imrotate(I, -1 * ang, 'bicubic');     %ang分逆回転
imtool(Irot);

%% さらに、領域の下の部分の縁へ、直線を近似して傾きを再修正
BW2 = imdilate(logical(Irot), strel('disk',4)); 
[C, Ind] = max(flipud(BW2));
Ind(Ind == 1) = [];                       %文字がない列を削除
y = polyfit(0:(size(Ind,2)-1), Ind, 1);   %直線をフィティング
ang2 = atan(y(1)) * (180/pi);             %直線の傾きから角度を計算
Irot2 = imrotate(Irot, -1 * ang2, 'bicubic');      %ang2の角度を逆回転
imtool(Irot2);

%% [別の方法] Hough変前にエッジ検出
BWedge = edge(BW);
figure; imshow(BWedge);

%% Hough変換し、角度を求め、逆回転補正
[H,theta,rho] = hough(BWedge);
peak = houghpeaks(H, 1)        % ピークの点のthetaとrhoの番号組
if theta(peak(1,2)) > 0
    ang = 90 - theta(peak(1,2));
else
    ang = -1 * (90 + theta(peak(1,2)));
end
Irot2 = imrotate(I, -1 * ang, 'bicubic');    %ang分逆回転
imtool(Irot2);

%%
% This is modified version of the following example.
% http://www.mathworks.com/help/releases/R2014a/vision/examples/text-rotation-correction.html
%
% Copyright 2014 The MathWorks, Inc.

