%% 正弦波デモ
% 初期化
clear;clc;close all;imtool close all

%% 文法の基本
t = 0:10             % ベクトルの作成、変数宣言不要。スクリプト言語
a = t+1              % ベクトルや多次元配列のまま計算。
b = sin(t)

%% 正弦波の描画 (基本操作)
t = 0:0.1:1          % 時間ベクトル
y = sin(2 * pi * 1 * t)  % 正弦波の生成 sin(2πft): ベクトルのまま計算
       % 可視化機能：プロット plot(t,y)   プロットTabから

%% 高サンプリング周波数の正弦波生成・音声再生 %%%%%%%%%%%%%%%%%%%%%%%
Fs = 44100;                   % サンプリング周波数 (44.1kHz)
t  = 0 : 1/Fs : 1;            % 1秒間分の時間ベクトル

%% 440Hzの正弦波の生成･再生
tone1 = sin(2 * pi * 440  * t);
figure; plot(t, tone1);
xlim([0 0.02]);          
sound(tone1,Fs);                  % 音声再生

%% 4184Hzの正弦波の生成･再生
tone2 = sin(2 * pi * 4184 * t);   % 4184Hz
figure; plot(t, tone2); xlim([0 0.02]);
sound(tone2,Fs);

%% 2つの正弦波の合成
tone3 = tone1 + tone2;            % 440Hz + 4184Hz 
figure; plot(t, tone3); xlim([0 0.02]);
sound(tone3,Fs);

%% fft : 周波数軸プロット (セクション実行)
nfft    = 2^16;                         % fftポイント
f       = 0 : Fs/nfft : Fs - Fs/nfft;   % 周波数ベクトル
TONES    = fft(tone3, nfft); % 時間軸から周波数軸に変換 (2^16 FFTポイント)
TONESpow   = abs(TONES);
figure; plot(f, TONESpow);xlim([0 5000]);

%% フィルタの作成
% ウィンドウ ベースの有限インパルス応答フィルターの係数の計算
%   B(z)=b(1) + b(2)z-1 + .... + b(n+1)z-N
[num, den] = fir1(20, 1000/(Fs/2))       % フィルタ伝達関数設計  20次   カットオフ1000Hz
fvtool(num,den);

%% フィルタリング･結果表示
tone3_f  = filter(num, den, tone3);
subplot(2,1,1); plot(t, tone3  ); xlim([0 0.02]); %元波形表示
subplot(2,1,2); plot(t, tone3_f); xlim([0 0.02]);

%% フィルタリング前後の音の再生
sound(tone3  , Fs);      % フィルタを掛ける前の音
sound(tone3_f, Fs);      % フィルタを掛けた後の音

%% 画像処理






%% 画像変換 %%%%%%%%%%
load clown                % MATファイルから、画像データ'X'、カラーマップmapの読込み
figure;imshow(X,map);     % 表示
[x,y,z]=cylinder;         % 円柱座標生成
figure;mesh(x,y,z,'edgecolor',[0 0 0]);axis square;  %座標表示
warp(x,y,z,flipud(X),map);axis square;shg  %テクスチャマッピング

%% 物体認識 %%%%%%%%%%%
RGB = imread('tape.png');      %画像読込み
figure;imshow(RGB);            %画像表示

%% 円検出
[center, radius] = imfindcircles(RGB,[60 100],'Sensitivity',0.9) %円検出

%% 結果を描画
viscircles(center,radius);
hold on; plot(center(:,1),center(:,2),'yx','LineWidth',4);hold off; % 中心点表示
message = sprintf('The estimated radius is %2.1f pixels', radius);
text(15,300,sprintf('radius : %2.1f', radius), 'Color','y','FontSize',20);shg

%%
% Copyright 2014 The MathWorks, Inc.
