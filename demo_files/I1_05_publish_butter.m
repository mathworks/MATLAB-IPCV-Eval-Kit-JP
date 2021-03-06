%% バタワースフィルタの設計とフィルタリング
% 本デモは、雑音を加えた2トーン正弦波に対して、バタワースローパスフィルタを
% かける手順と、グラフの可視化の手順を示します。一般的なデジタルフィルタの
% 伝達関数は以下の表現で表わされます。
% 
% $$ H(z) = \frac{\sum^{N}_{k = 0}b_kZ^{-k}}{1 + \sum^{N}_{k = 1}a_kZ^{-k}} $$  
%% 初期化
clear all, close all, clc

%% フィルタリング対象の信号生成
Fs = 1000;
t = 0:1/Fs:1;                   % 時間ベクトルの定義
sig1 = sin(2*pi*15*t + pi/3);   % 正弦波信号1の生成
sig2 = sin(2*pi*42*t + pi/5);   % 正弦波信号2の生成
noise = randn(size(t));         % 雑音信号の生成
sig = sig1 + sig2 + noise;      % フィルタリング対象信号

%% フィルタ設計と特性の可視化
% フィルタの次数を7次、ナイキスト周波数で正規化されたカットオフ
% 周波数を0.1としたフィルタを設計します。Fs = 1000[Hz]の場合、
% カットオフ周波数は、1000/2 * 0.1 = 50[Hz]となります。
[b,a] = butter(7,0.1); % バタワースフィルタ設計
fvtool(b, a) % フィルタ特性の可視化

%% フィルタリング
out = filter(b,a,sig); % フィルタリング
% 入力信号と出力信号の時間軸波形可視化
subplot(2,1,1), plot(t,sig), grid
title('時間軸波形（フィルタリング前）')
subplot(2,1,2), plot(t,out), grid
title('時間軸波形（フィルタリング後）')

%% スペクトル推定
% ローパスフィルタにより、50[Hz]以下の成分が除去されている様子が
% 確認できます。
figure, periodogram(sig,[],[],Fs)    % 入力信号のスペクトル
title('パワースペクトル密度推定（フィルタリング前）')
figure,periodogram(out,[],[],Fs)    % 出力信号のスペクトル
title('パワースペクトル密度推定（フィルタリング後）')


% Copyright 2014 The MathWorks, Inc.
