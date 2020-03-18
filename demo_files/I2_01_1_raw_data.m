%% 初期化
clc;close all;clear;

%% Rawデータの読込み
fid = fopen('I2_01_1_onion.raw', 'r', 'b');            % ファイルを開く　モード:読取り、ビックエンディアン
G = (fread(fid, [198, 135], '*uint16', 'b'))'; % ファイルの読込み・転置。*があると出力も同じ型。b：ビックエンディアン
figure;imshow(G);                              % 表示
fclose(fid);                                   % ファイルを閉じる

%% メモリマッピングを使った読込み
%  メモリ マッピングは、ディスク上のファイルの一部または全体を、
%  アプリケーションのアドレス空間内の一定のアドレス範囲に
%  マッピングする方法です。これによってアプリケーションでは、
%  動的メモリへのアクセスと同様にディスク上のファイルにアクセスできるようになります。
%  fread や fwrite などのIO関数を使用する場合に比べ、
%  ファイルの読み取りと書き込みが高速化します。
% 
% 大規模ファイルにランダムアクセスする場合や小さなファイルに頻繁にアクセスする場合等にも 
m = memmapfile('I2_01_1_onion.raw')
m.Format =  'uint16'               % Endianは、OS固有のものが使われる (Windows：Little)

% Endianの変更
I1 = mod(m.Data, 256) * 256 + (m.Data/256);   % m.Repeat = Infなので、全データを取込み
figure;imshow(reshape(I1, 198, 135)');

% memmapfileのクリア
clear m;

%% 終了





%% [参考] サンプルデータの生成スクリプト（Rawデータの書出し）
g = im2uint16(rgb2gray(imread('onion.png')));   % 画像の読込：135x198 pixels
imtool(g);

fid = fopen('I2_01_1_onion.raw', 'w', 'b');  % ファイルを開く　モード:書込み、ビッグエンディアン
fwrite(fid, g', 'uint16', 'b');      % ビッグエンディアンで書出し
fclose(fid);                         % ファイルを閉じる

%% Copyright 2014 The MathWorks, Inc.

