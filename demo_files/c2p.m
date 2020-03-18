function X = c2p( U, T)
% 写像関数 : 正規座標系から、極座標系へ写像
%   カスタム変換による画像変換で使用
[th,r] = cart2pol(U(:,1),U(:,2));
X(:,1) = th;
X(:,2) = r;


% Copyright 2014 The MathWorks, Inc.

