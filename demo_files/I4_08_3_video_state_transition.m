function x_k = video_state_transition(pf, x_k_1)
% 等速度モデル
%   x_k_1 : Nx6の配列

% 状態ベクトル = [x, xd, xdd, y, yd, ydd]

% 状態遷移モデル
stateTransitionModel = ...
    [1     1     0     0     0     0;
     0     1     1     0     0     0;
     0     0     1     0     0     0;
     0     0     0     1     1     0;
     0     0     0     0     1     1;
     0     0     0     0     0     1 ];

% ノイズ（正規分布の分散）
% processNoise = ...
%     [25     0     0     0     0     0;
%      0     10     0     0     0     0;
%      0      0    10     0     0     0;
%      0      0     0    25     0     0;
%      0      0     0     0    10     0;
%      0      0     0     0     0    10];
   
   processNoise = ...
    [1      0     0     0     0     0;
     0      1     0     0     0     0;
     0      0   0.5     0     0     0;
     0      0     0     1     0     0;
     0      0     0     0     1     0;
     0      0     0     0     0   0.5];
   
   
   

N = pf.NumParticles;      % 粒子数を取得
R = chol(processNoise);   % 要素が平方根値へ
noise = randn(N,6) * R';

% 全粒子の、次状態を計算（ガウシアンノイズを印加）
%    全粒子を一括計算するために、行列の積の形を入れ替え
x_k =  x_k_1 * stateTransitionModel' + noise;

end

% Copyright 2018 The MathWorks, Inc.