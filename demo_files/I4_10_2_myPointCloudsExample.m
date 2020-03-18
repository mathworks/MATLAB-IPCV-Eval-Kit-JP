%% 3次元点群の 表示・位置合わせ・結合
clc;clear;close all;imtool close all;

%% unorganized 3次元点群のPLY形式のデータの読み込み（pointCloud クラス）%%%%%%%%
ptCloud = pcread('teapot.ply')   % 41472個のx,y,zの組：コマンド ウィンドウ参照

%% 例）1番目の点の、x,y,z座標
ptCloud.Location(1,:)

%% 表示 (色データがないので、Z軸方向にグラデーション色表示)
figure; pcshow(ptCloud);
xlabel('X'); ylabel('Y'); zlabel('Z'); box on

%% 別のデータセット：unorganizedの3次元点群の処理
% 点群データの読み込み
load('object3d.mat')

%% 点群の表示
figure
pcshow(ptCloud)
xlabel('X(m)')
ylabel('Y(m)')
zlabel('Z(m)')
title('Original Point Cloud')

%% テーブルの検出(平面フィッティング)
% 平面フィッティングのパラメータの設定
maxDistance = 0.02;
referenceVector = [0,0,1];
maxAngularDistance = 5;
[model1,inlierIndices,outlierIndices] = pcfitplane(ptCloud,...
            maxDistance,referenceVector,maxAngularDistance);
plane1 = select(ptCloud,inlierIndices);
remainPtCloud = select(ptCloud,outlierIndices);
figure
pcshow(plane1)
title('最初の平面')

%% 左の壁面の検出(平面フィッティング)
roi = [-inf,inf;0.4,inf;-inf,inf];
sampleIndices = findPointsInROI(remainPtCloud,roi);
[model2,inlierIndices,outlierIndices] = pcfitplane(remainPtCloud,...
            maxDistance,'SampleIndices',sampleIndices);
plane2 = select(remainPtCloud,inlierIndices);
remainPtCloud = select(remainPtCloud,outlierIndices);
figure
pcshow(plane2)
title('2番目の平面')

%% 奥の壁面の検出(平面フィッティング)
roi = [-inf,inf;-inf,inf;-inf,inf];
sampleIndices = findPointsInROI(remainPtCloud,roi);
[model3,inlierIndices,outlierIndices] = pcfitplane(remainPtCloud,...
            maxDistance,'SampleIndices',sampleIndices);
plane3 = select(remainPtCloud,inlierIndices);
remainPtCloud = select(remainPtCloud,outlierIndices);
figure
pcshow(plane3)
title('3番目の平面')

%% 残りの点群の表示
figure
axPc = pcshow(remainPtCloud);
axis([ptCloud.XLimits, ptCloud.YLimits, ptCloud.ZLimits]);
hold on;
plot(model1,'Color','yellow');
alpha(0.5);
plot(model2,'Color','magenta');
alpha(0.5);
plot(model3,'Color','cyan');
alpha(0.5);
title('残りの点群を表示')

%% 点群のセグメンテーション
distThreshold = 0.1;
[labels,numClusters] = pcsegdist(remainPtCloud,distThreshold);
cmap = lines(numClusters);
for k = 1:numClusters
    pc = select(remainPtCloud,find(labels==k));
    I4_10_2_plot3DBBox(pc,cmap(k,:),gca);
end
title('点群のセグメンテーション(クラスタリング)')
shg;

%% 別のデータセット：organized 3次元点群データの読込み %%%%%%%%%%%%%%%%%%%%%%%%%
%    livingRoomData: 44枚のPointCloudデータ（各点がworld座標値と、色を持つ）
load('livingRoom.mat');

%% 1枚目のデータを抽出
ptCloudRef = livingRoomData{1}   %1番目のデータをリファレンスPointCloudとする

%% 例）(100,100)の x,y,z座標
ptCloudRef.Location(100, 100, :)

%% 色データ(カラー画像)を表示
figure; imshow(ptCloudRef.Color); title('1st');

%% 3次元点群データを表示
figure; pcshow(ptCloudRef, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down', 'MarkerSize',18);
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)'); title('1st'); view(0,-90); box on;

%% 2番目のデータを抽出・並べて表示
ptCloudCurrent = livingRoomData{2};
% 表示
subplot(1,2,1);pcshow(ptCloudRef, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down', 'MarkerSize',18);
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)'); title('1st'); view(0,-90);box on
subplot(1,2,2);pcshow(ptCloudCurrent, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down', 'MarkerSize',18);
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)'); title('2nd'); view(0,-90);box on; shg;

%% 2つの点群データを重ねて表示
figure; pcshowpair(ptCloudRef, ptCloudCurrent, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down');
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)'); box on

%% [前処理] PointCloudのデータ点を間引き（オリジナルは307,200データ点 => 約1500データ点へ）
%    立方体(box grid)内の全点の座標を平均して1つの点に集約
%    位置あわせの速度ならびに精度の改善（pcdenoiseの使用はオプショナル）
gridSize = 0.1;   % 10cm角　（点群データのX,Y,Z値の単位がm）
fixed = pcdownsample(ptCloudRef, 'gridAverage', gridSize);
moving = pcdownsample(ptCloudCurrent, 'gridAverage', gridSize);

% 表示
figure;
subplot(1,2,1);pcshow(fixed, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down', 'MarkerSize',18);
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)'); title('1st'); view(0,-90);box on
subplot(1,2,2);pcshow(moving, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down', 'MarkerSize',18);
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)'); title('2nd'); view(0,-90);box on; shg;

%% ICP(iterative closest point) algorithmによるレジストレーション
% レジストレーション（2つの点群間の変換行列を推定）
tformICP = pcregistericp(moving, fixed, 'Metric','pointToPlane','Extrapolate', true)
tformICP.T     % 変換(射影)行列を確認

% (間引きなしのデータに対し) 幾何学的変換し、2番目の点群を、1番目の点群の座標へ変換･表示
ptCloudAlignedICP = pctransform(ptCloudCurrent, tformICP);

%表示
subplot(2,2,1);pcshow(ptCloudRef, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down', 'MarkerSize',18);
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)'); title('1st'); view(0,-90); box on;
subplot(2,2,2);pcshow(ptCloudCurrent, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down', 'MarkerSize',18);
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)'); title('2nd'); view(0,-90); box on;
subplot(2,2,3);pcshow(ptCloudAlignedICP, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down', 'MarkerSize',18);
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)'); title('2nd (Aligned with ICP)'); view(0,-90); box on; shg;

%% NDT(normal-distributions transform) algorithmによるレジストレーション
% レジストレーション（2つの点群間の変換行列を推定）
gridStep = 0.5;
tformICP = pcregisterndt(moving,fixed,gridStep)
tformICP.T     % 変換(射影)行列を確認

% (間引きなしのデータに対し) 幾何学的変換し、2番目の点群を、1番目の点群の座標へ変換･表示
ptCloudAlignedNDT = pctransform(ptCloudCurrent, tformICP);

%表示
subplot(2,2,4);pcshow(ptCloudAlignedNDT, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down', 'MarkerSize',18);
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)'); title('2nd (Aligned with NDT)'); view(0,-90); box on; shg;

%% CPD(coherent point drift)アルゴリズムによる非剛体点群レジストレーション
% 2つの点群間の対応関係から適用先の各点群のdisplacementを推定
tformCPD = pcregistercpd(moving,fixed);

% 2番目の点群を、1番目の点群の座標へ変換
% (幾何学変換行列の推定ではなく、
% 点群間のdisplacementを計算しているためダウンサンプルしたものに適用)
ptCloudAlignedCPD = pctransform(moving, tformCPD);

%表示
figure; pcshow(ptCloudAlignedCPD, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down', 'MarkerSize',18);
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)'); title('2nd (Aligned with CPD)'); view(0,-90); box on; shg;

%% 2つの3次元点群を統合･表示
mergeSize = 0.015;   % 1.5cmのbox grid filterで、重複領域をフィルタリング。
                     % box内に複数点がある場合、位置・色の平均を計算
ptCloudSceneICP = pcmerge(ptCloudRef, ptCloudAlignedICP, mergeSize);

% 表示
subplot(1,2,1);pcshow(ptCloudRef, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down', 'MarkerSize',18);
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)'); title('1st'); view(0,-90); box on
subplot(1,2,2);pcshow(ptCloudSceneICP, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down', 'MarkerSize',18);
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)'); title('Stitched (1st+2nd)'); view(0,-90);box on; shg;

%% 3番目以降の点群も結合していく
accumTformICP = tformICP; 

figure;
hAxes = pcshow(ptCloudSceneICP, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down', 'MarkerSize',18);
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)'); box on
% Axesのプロパティーをセット（描画の高速化）
hAxes.CameraViewAngleMode = 'auto';
hScatter = hAxes.Children;

for i = 3:44      %length(livingRoomData)
    % 次のポイントクラウドデータを読込み
    ptCloudCurrent = livingRoomData{i};
    % 一つ前のポイントクラウドデータをリファレンスとして設定
    fixed = moving;
    % ポイントクラウドのデータを間引き
    moving = pcdownsample(ptCloudCurrent, 'gridAverage', gridSize);
    
    % ICP 位置あわせを適用
    tformICP = pcregistericp(moving, fixed, 'Metric','pointToPlane','Extrapolate', true);

    % 最初の画像の座標系へ変換
    accumTformICP = affine3d(tformICP.T * accumTformICP.T);
    ptCloudAlignedICP = pctransform(ptCloudCurrent, accumTformICP);
    
    % 点群の結合
    ptCloudSceneICP = pcmerge(ptCloudSceneICP, ptCloudAlignedICP, mergeSize);

    % Visualize the world scene.
    hScatter.XData = ptCloudSceneICP.Location(:,1);
    hScatter.YData = ptCloudSceneICP.Location(:,2);
    hScatter.ZData = ptCloudSceneICP.Location(:,3);
    hScatter.CData = ptCloudSceneICP.Color;
    drawnow limitrate;
end  

%% 床の面を推定するためのパラメータを定義
maxDistance = 0.01;                 % 推定した面とinlier点の最大距離 (1cm)
referenceVector = [0, 5, 1.5];      % 参照用 面の法線ベクトル
% 参照用の法線ベクトルと、推定する面の法線ベクトルの許容最大誤差（絶対値）
maxAngularDistance = 5;
rng('default');

%% 参照用の法線ベクトルに近い面を推定
[model1, inlierIndices, outlierIndices] = ...
      pcfitplane(ptCloudSceneICP,maxDistance,referenceVector,maxAngularDistance);
model1        % planeModel オブジェクト: ax+by+cz+d=0 の係数、法線ベクトル

%% 全3次元点群データに、推定した面を重ね書き
figure; pcshow(ptCloudSceneICP, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down', 'MarkerSize',18); hold on;
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)'); box on

h1 = plot(model1); hold off
h1.FaceAlpha = 0.5;

%% 推定した床面を、XZ平面に平行にする･表示
angle = -1*atan(model1.Normal(3)/model1.Normal(2))
A = [1,           0,          0, 0;...
     0,  cos(angle), sin(angle), 0; ...
     0, -sin(angle), cos(angle), 0; ...
     0,           0,          0, 1];
ptCloudScene1 = pctransform(ptCloudSceneICP, affine3d(A));

figure; pcshow(ptCloudScene1, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down', 'MarkerSize',18)
xlabel('X (m)');ylabel('Y (m)');zlabel('Z (m)'); box on;

%%  終了













%% 回転角を行列への変換
rotationVectorToMatrix([0, 0,  -0.2691])

%% 推定した床面上の点のみを抽出･表示
plane1 = select(ptCloudSceneICP,inlierIndices);
figure;pcshow(plane1, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down', 'MarkerSize',18);
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)'); box on


%% スチッティングをICPとNDTで比較
% organized 3次元点群データの読込み %%%%%%%%%%%%%%%%%%%%%%%%%
% livingRoomData: 88枚のPointCloudデータ（各点がworld座標値と、色を持つ）
load('livingRoom.mat');
sz = get(groot,'ScreenSize');
% Stop ボタン表示
a=true;
figure('MenuBar','none','Toolbar','none','Position',[20 sz(4)-100 100 70]);
uicontrol('Style', 'pushbutton', 'String', 'Stop',...
        'Position', [20 20 80 40], 'Callback', 'a=false;');

figure;
title('Updated world scene');
gridSize = 0.1;   % 10cm角
mergeSize = 0.015;   % 1.5cmのbox grid filterで、重複領域をフィルタリング

while (a)
ptCloudRef = livingRoomData{1};
ptCloudCurrent = livingRoomData{2};
fixed  = pcdownsample(ptCloudRef, 'gridAverage', gridSize);
moving = pcdownsample(ptCloudCurrent, 'gridAverage', gridSize);
tformICP = pcregistericp(moving, fixed, 'Metric','pointToPlane','Extrapolate', true);
tformNDT = pcregisterndt(moving, fixed, 0.5);
ptCloudAlignedICP = pctransform(ptCloudCurrent, tformICP);
ptCloudAlignedNDT = pctransform(ptCloudCurrent, tformNDT);
ptCloudSceneICP = pcmerge(ptCloudRef, ptCloudAlignedICP, mergeSize);
ptCloudSceneNDT = pcmerge(ptCloudRef, ptCloudAlignedNDT, mergeSize);

accumTformICP = tformICP; 
accumTformNDT = tformNDT; 

ax = subplot(1,2,1);
hAxes = pcshow(ptCloudSceneICP, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down', 'MarkerSize',18, 'Parent',ax);
title('ICP');
ax = subplot(1,2,2);
hAxes2 = pcshow(ptCloudSceneNDT, 'VerticalAxis','Y', 'VerticalAxisDir', 'Down', 'MarkerSize',18, 'Parent',ax);
title('NDT');
% Axesのプロパティーをセット（描画の高速化）
hAxes.CameraViewAngleMode = 'auto';
hAxes2.CameraViewAngleMode = 'auto';
hScatter = hAxes.Children;
hScatter2 = hAxes2.Children;

for i = 3:44      %length(livingRoomData)
    if (~a)
        break;
    end
    % 次のポイントクラウドデータを読込み
    ptCloudCurrent = livingRoomData{i};
    % 一つ前のポイントクラウドデータをリファレンスとして設定
    fixed = moving;
    % ポイントクラウドのデータを間引き
    moving = pcdownsample(ptCloudCurrent, 'gridAverage', gridSize);
    
    % ICP 位置あわせを適用
    tformICP = pcregistericp(moving, fixed, 'Metric','pointToPlane','Extrapolate', true);
    tformNDT = pcregisterndt(moving, fixed, 0.5);

    % 最初の画像の座標系へ変換
    accumTformICP = affine3d(tformICP.T * accumTformICP.T);
    ptCloudAlignedICP = pctransform(ptCloudCurrent, accumTformICP);
    accumTformNDT = affine3d(tformICP.T * accumTformNDT.T);
    ptCloudAlignedNDT = pctransform(ptCloudCurrent, accumTformNDT);
    
    % 点群の結合
    ptCloudSceneICP = pcmerge(ptCloudSceneICP, ptCloudAlignedICP, mergeSize);
    ptCloudSceneNDT = pcmerge(ptCloudSceneNDT, ptCloudAlignedNDT, mergeSize);

    % Visualize the world scene.
    hScatter.XData = ptCloudSceneICP.Location(:,1);
    hScatter.YData = ptCloudSceneICP.Location(:,2);
    hScatter.ZData = ptCloudSceneICP.Location(:,3);
    hScatter.CData = ptCloudSceneICP.Color;
    hScatter2.XData = ptCloudSceneNDT.Location(:,1);
    hScatter2.YData = ptCloudSceneNDT.Location(:,2);
    hScatter2.ZData = ptCloudSceneNDT.Location(:,3);
    hScatter2.CData = ptCloudSceneNDT.Color;
    drawnow limitrate;
end  

end   %while




%% Copyright 2015 The MathWorks, Inc.

