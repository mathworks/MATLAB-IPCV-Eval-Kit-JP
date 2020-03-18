%% CNN による画像のガテゴリ分類
% USBカメラの画像から、
%  カップ、ラップトップPC、ピザ、腕時計、 の認識

%% 初期化
clc;close all;imtool close all;clear;imaqreset;

%% 学習済みの分類器の読込み
if ~exist('I5_06_2_2_myCNNTransferLearning.mat','file')
    error('<a href="matlab:edit I5_06_2_2_myCNNTransferLearning.m">I5_06_2_2_myCNNTransferLearning.m</a>で学習を実行してください。');
end
d = load('I5_06_2_2_myCNNTransferLearning.mat');
convnet = d.netTransfer;

%% USB カメラからビデオを取込むオブジェクトの定義
vidobj = imaq.VideoDevice('winvideo', 1, 'RGB24_320x240');
vidobj.ReturnedDataType = 'uint8';

%% PCの画面にビデオを表示するビューワの定義
viewer = vision.DeployableVideoPlayer;

%% ボタン表示
a=true;
b=false;
sz = get(0,'ScreenSize');
figure('MenuBar','none','Toolbar','none','Position',[20 sz(4)-170 100 140])
uicontrol('Style', 'pushbutton', 'String', 'Stop',...
        'Position', [20 20 80 40],'Callback', 'a=false;');
uicontrol('Style', 'pushbutton', 'String', 'Recog On',...
        'Position', [20 80 80 40],'Callback', 'b=true;');

%% カメラから1フレームずつ読込み処理をする
while (a) 
  I = step(vidobj);              % カメラから1画面取込み
  I1 = I([7:233], [47:273], :);  % サイズを 227x227へ

  [labels, scores] = classify(convnet, I1);
  
  if b
    I = insertText(I, [1 1], ['Cu La Pi Wa: ' num2str(scores, '%6.2f')], 'FontSize', 14);
   
    Smax = max(scores); 
    if (Smax > -0.2)
      I = insertText(I, [80 80], cellstr(labels), 'FontSize',32); 
    end
  end
  step(viewer, I);
  
  drawnow limitrate;      % プッシュボタンのイベントの確認
end

%%
release(vidobj);
release(viewer);

%% Copyright 2018 The MathWorks, Inc. 