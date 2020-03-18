%% つながっているUSBカメラのリストを表示
webcamlist

%% カメラから画像を取込むオブジェクトを生成
camera = webcam('Logicool HD Pro Webcam C920')    %上記 webcamlistで表示されたものの中から、使用するカメラを指定
% camera = webcam       %この記述方は、USBカメラが1つのみつながっている場合のみ可能

camera.AvailableResolutions
camera.Resolution = '640x480'    %取込む画像の解像度を設定

% preview(camera)       % プレビューする為の関数

%% ビデオを表示するためのオブジェクトの生成
viewer = vision.DeployableVideoPlayer;
 
%% フレームレートを書き込むためのオブジェクトを生成
fps = single(0.0);
texts = vision.TextInserter('Running at %2.2f fps', ...
  'Color',[0, 255, 0], 'FontSize',30, 'Location',[20 20]); 
 
%% フレームレート計測用
t = tic();
cnt = 1;

%% ストップボタンの表示
a=true;
sz = get(0,'ScreenSize');
figure('MenuBar','none','Toolbar','none','Position',[20 sz(4)-100 100 70])
uicontrol('Style', 'pushbutton', 'String', 'Stop',...
        'Position', [20 20 80 40],...
        'Callback', 'a=false;');

%% 1フレーム毎に処理するためのループ処理
while (a)
% for i=1:200 
  I = snapshot(camera);        %1フレーム取り込み (uint8)
  Itxt = step(texts,I,fps);    %フレームレートの書込み
  step(viewer,Itxt);           %フレーム表示

   % 30フレームの平均からフレームレートの計算
   cnt = cnt + 1;
   if (mod(cnt,30) == 0)
    t = toc(t);
    fps = single(30/t);
    t = tic();
   end
  drawnow limitrate;
end

%%
clear('camera');
release(viewer);
release(texts);

%%
%  Copyright 2014 The MathWorks, Inc.

