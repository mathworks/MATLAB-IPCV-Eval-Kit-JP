function lhood = video_measurement(pf, x_k_hat, z_k)
% 各粒子の尤度を返す
%   x_k_hat (N-by-6) : 予測ステップで予測された、各粒子の状態ベクトル
%   z_k (1-by-2) : correctの第2引数 => 検出されたボールの位置

% 状態ベクトル = [x, xd, xdd, y, yd, ydd]
N = pf.NumParticles;    % 粒子数

% 観測エラー
measurementNoise = ...
    [25  0; 
      0 25];
  
% 観測行列：座標xとyを測定
measurementModel = ...
    [1 0 0 0 0 0;
     0 0 0 1 0 0];

% 予測された全粒子の状態ベクトルから、予測される観測座標位置を計算
z_hat = x_k_hat * measurementModel';      % サイズ：Nx2

% 測定されたボール位置と、予測された全粒子位置の差を計算
z_error = abs(repmat(z_k, N, 1) - z_hat); % サイズ：Nx2

% 直線距離へ変換（error norm）
z_norm = sqrt(sum(z_error.^2, 2));        % サイズ：Nx1

% 尤度を算出
%（多変量正規分布：multivariate normal distributionの確率密度関数を使い計算）
lhood = 1/sqrt((2*pi).^3 * det(measurementNoise)) * exp(-0.5 * z_norm);
end


% Copyright 2018 The MathWorks, Inc.