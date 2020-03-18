%% Homomorphic Filtering
%   I1 = I  + N     の形でノイズが乗っているのではなく
%   I1 = I .* R     の形で画像が影響を受けている場合（照度変化等）に、Rを取除く
%    NやRの周波数が、I と遠い場合
%      Log変換をすることで、I成分とR成分を和の形で分離化
% 詳細は
%   http://blogs.mathworks.com/steve/2013/06/25/homomorphic-filtering-part-1
%   http://blogs.mathworks.com/steve/2013/07/10/homomorphic-filtering-part-2

%% 画像の読込み
I = imread('AT3_1m4_01.tif');
figure;imshow(I);

%% Log変換
Id = im2double(I);      % 0~1
Il = log(Id + 1);        % 正にするために、1を加える

%% ハイパス フィルタ 係数の設定（Spacial Domain）
filterRadius = 10;
filterSize = 2*filterRadius + 1;
hLowpass = fspecial('average', filterSize);
hImpulse = zeros(filterSize);
hImpulse(filterRadius+1,filterRadius+1) = 1;
hHPF = hImpulse - hLowpass;      % ラプラシアン型
figure,freqz2(hHPF)              % 2次元フィルタ周波数応答表示

%% ハイパス フィルタ 処理
Ilf = imfilter(Il, hHPF, 'replicate');

%% exp関数で、Log変換を戻す・表示
If = exp(Ilf) - 1;
imshowpair(I, If, 'montage'); shg;

%% 終了





%% 周波数ドメインでのフィルタリングの例は下記参照
%%    http://blogs.mathworks.com/steve/2013/06/25/homomorphic-filtering-part-1

% Copyright 2016 The MathWorks, Inc.