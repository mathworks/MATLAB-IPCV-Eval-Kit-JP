%% 強い光源を含む画像から
% 定点カメラで動いていない物体を異なる露光度で撮影した複数枚の画像を取り込み
I1 = imread('car_1.jpg');
I2 = imread('car_2.jpg');
I3 = imread('car_3.jpg');
I4 = imread('car_4.jpg');
montage({I1,I2,I3,I4})
%% 
% blendexposure関数で露光度が異なる複数舞の画像を融合して一つの画像を作成
E = blendexposure(I1,I2,I3,I4);
% 強い光源の強度を抑える機能をOFFにした結果も合わせて表示
F = blendexposure(I1,I2,I3,I4,'ReduceStrongLight',false); 
montage({E,F})
title('Exposure Fusion With (Left) and Without (Right) Strong Light Suppression')

%% 
% Copyright 2018 The MathWorks, Inc.