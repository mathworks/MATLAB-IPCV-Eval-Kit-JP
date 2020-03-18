function X = p2c( U, T)
% 写像逆関数 : 極座標系から、正規座標系へ写像
%   カスタム変換による画像変換で使用
[x,y] = pol2cart(U(:,1),U(:,2));
X(:,1) = x;
X(:,2) = y;

%  Copyright 2014 The MathWorks, Inc.
