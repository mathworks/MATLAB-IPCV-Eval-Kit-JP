%% MTB(Median Threshold Bitmap)を用いた画像のレジストレーション
% 異なる露光度の画像の取り込み
I1 = imread('office_1.jpg');
I2 = imread('office_2.jpg');
I3 = imread('office_3.jpg');
I4 = imread('office_4.jpg');
I5 = imread('office_5.jpg');
I6 = imread('office_6.jpg');
%% 画像の位置をランダムに移動
t = randi([-30 30],5,2);
I1 = imtranslate(I1,t(1,:));
I2 = imtranslate(I2,t(2,:));
I3 = imtranslate(I3,t(3,:));
I4 = imtranslate(I4,t(4,:));
I5 = imtranslate(I5,t(5,:));
%% 指定したROIで切り出し表示
roi = [140 260 200 200];
montage({imcrop(I1,roi),imcrop(I2,roi),imcrop(I3,roi), ...
    imcrop(I4,roi),imcrop(I5,roi),imcrop(I6,roi)})
title('Misaligned Images')
%% MTBを用いてレジストレーション
[R1,R2,R3,R4,R5,shift] = imregmtb(I1,I2,I3,I4,I5,I6);
montage({imcrop(R1,roi),imcrop(R2,roi),imcrop(R3,roi), ...
    imcrop(R4,roi),imcrop(R5,roi),imcrop(I6,roi)})
title('Registered Images')
%% レジストレーションの際の移動量と与えた移動量を比較
shift % レジストレーションの移動量

-t % 最初に与えた移動量
% おおよそ同じ値になっているか確認
%% 
% Copyright 2018 The MathWorks, Inc.
