%% GPU Coder デモ : Bilateral Filterの高速化
% Bilateral Filterはエッジキープ型のフィルタとしても良く知られており、
% 医用画像処理など様々な分野で用いられています。
% 輝度差に応じて重み付け計算を行う必要があるため、
% ループ文で局所領域を抽出 > 重み計算 > フィルタリング、といった流れになります。
%
% 処理自体はいわゆるステンシル計算の一種となりますが、これをGPU Coderを使って
% 高速化を行います。
%
% 本デモを実行するためには、GPUが搭載されているマシンが必要となります。
% 実行に必要なデバイス、ツール等の準備につきましては、下記ドキュメントをご覧ください.
% <https://www.mathworks.com/help/releases/R2017b/gpucoder/getting-started-with-gpu-coder.html>
% 

clear; close all; clc;
%% ビデオ読み取り用&ビューワーオブジェクトの定義
videoFReader = vision.VideoFileReader('potholes2.avi');
videoPlayer = vision.VideoPlayer;

%% フレームレート計測用変数定義
t = tic();
cnt = 1;
fps = single(0.0);

%% Stop ボタン表示
a=true;
sz = get(0,'ScreenSize');
figure('MenuBar','none','Toolbar','none','Position',[20 sz(4)-100 100 70])
uicontrol('Style', 'pushbutton', 'String', 'Stop',...
        'Position', [20 20 80 40],...
        'Callback', 'a=false;');

%% ループ再生
reset(videoFReader)
while ~isDone(videoFReader) && a
    videoFrame = videoFReader(); %1フレーム読み込み
    bimg = bfilter2cGPC(videoFrame); %Bilateral Filter処理
    bimg = insertText(bimg, [20 20], ['Running at ' num2str(round(fps,2)) 'fps'],...
        'Font', 'Calibri', 'FontSize', 14, 'BoxOpacity',0.6,'TextColor','black');
    
    videoPlayer([videoFrame bimg]);
    
   % 時間計測
   % 5フレームの所要時間からフレームレートを計測
   cnt = cnt + 1;
   if (mod(cnt,5) == 0)
       t = toc(t);
       fps = single(5/t);
       t = tic();
   end

end

%% GPU Coderを利用してMEX生成
cfg = coder.gpuConfig('mex');
codegen -args {videoFrame} -config cfg bfilter2cGPC -o bfilter2cGPC_mex

%% ループ再生
t = tic();
cnt = 1;
a = true;
fps2 = single(0.0);
reset(videoFReader)
reset(videoPlayer)
while ~isDone(videoFReader)
    videoFrame = videoFReader(); %1フレーム読み込み
    bimg = bfilter2cGPC_mex(videoFrame); %Bilateral Filter処理(MEX)
    bimg = insertText(bimg, [20 20], ['Running at ' num2str(round(fps2,2)) 'fps'],...
        'Font', 'Calibri', 'FontSize', 14, 'BoxOpacity',0.6,'TextColor','black');
    
    videoPlayer([videoFrame bimg]);
    
   % 時間計測
   % 5フレームの所要時間からフレームレートを計測
   cnt = cnt + 1;
   if (mod(cnt,5) == 0)
       t = toc(t);
       fps2 = single(5/t);
       t = tic();
   end

end

%% MEX化による高速化の割合
fps2 / fps

%%
release(videoFReader)
release(videoPlayer)

%% 
% Copyright 2018 The MathWorks, Inc.