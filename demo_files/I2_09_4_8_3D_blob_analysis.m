%% 3次元ボリュームデータの処理

%% 初期化
clear; close all; clc;

%% 半径5と10の球体を作成
[x,y,z] = meshgrid(1:50,1:50,1:50);
bw1 = sqrt((x-10).^2 + (y-15).^2 + (z-35).^2) < 5;
bw2 = sqrt((x-20).^2 + (y-30).^2 + (z-15).^2) < 10;
bw = bw1 | bw2;
figure
isosurface(bw)
alpha 0.3;
axis equal;

%% 重心と半径を計算
s = regionprops3(bw,"Centroid","PrincipalAxisLength");
centers = s.Centroid
diameters = mean(s.PrincipalAxisLength,2)
radii = diameters/2

[x,y,z] = sphere;
hold on 
for k = 1:size(s,1)
    surf(x*radii(k)+centers(k,1),y*radii(k)+centers(k,2),z*radii(k)+centers(k,3));
end

%% Brain Scan Demo (NIfTI image processing)
% 本デモでは、3次元の脳スキャンNIfTIデータを読み込み、
% 脳部分のみのボリューム表示を試みます

%% NIfTI画像の読み取り対応(R2017b)
% NIfTI (Neuroimaging Informatics Technology Initiative) 
D = niftiread('brain.nii');
figure, montage(permute(D,[1 2 4 3]),'DisplayRange',[]);

%% ボリュームデータの可視化
volumeViewer(D);

%% 非常に輝度の小さいものを削除
mriAdjust = D;
lb = 40;  % lower threshold (ignore CSF & air)
mriAdjust(mriAdjust <= lb) = 0;
figure, montage(mriAdjust,'DisplayRange',[]);

%% 頭蓋骨と接触している部分などの削除
ub = 140; % upper threshold (ignore skull & other hard tissue)
mriAdjust(mriAdjust >= ub) = 0;
figure, montage(mriAdjust,'DisplayRange',[]);

%% 不要な脳の下の領域を切り取り
mriAdjust(175:end,:,:)  = 0;
figure, montage(mriAdjust,'DisplayRange',[]);

%% ２値化
bw    = mriAdjust > 0;
figure, montage(bw,'DisplayRange',[]);

%% オープン処理である領域以下の部分を削除
nhood = ones([7 7 3]);
bw = imopen(bw,nhood);
figure, montage(bw,'DisplayRange',[]);

%% 脳の部分のセグメンテーションを行います
% regionpropsで中心点と面積を確認します
L       = bwlabeln(bw);
stats   = regionprops('table',L,'Area')

%% 最も面積が大きい部分を選択
A       = stats.Area;
biggest = find(A == max(A));
mriAdjust(L ~= biggest) = 0;
figure, montage(mriAdjust,'DisplayRange',[]);

%% コントラスト調整
%mriAdjust = imadjust(mriAdjust(:, :, 30));
%figure, montage(mriAdjust,'DisplayRange',[]);

%% 脳の部分のみ抽出して、表示
level = 65;
mriBrainPartition = uint8(zeros(size(mriAdjust)));    %0=outside brain (head/air)
mriBrainPartition(mriAdjust<level & mriAdjust>0) = 2; %2=gray matter
mriBrainPartition(mriAdjust>=level) = 3;              %3=white matter
figure,imshow(mriBrainPartition(:,:,10),[])

%% 脳部分のみの3次元表現
Ds = imresize(mriBrainPartition,0.25,'nearest');

% データの向きを修正
Ds = flip(Ds,1);
Ds = flip(Ds,2);
Ds = squeeze(Ds);
Ds = permute(Ds,[3 2 1]);

% ボクセルのスケーリング
voxel_size2 = [1 2 1]; %voxel_size([1 3 2]).*[4 1 4];

%白い部分とグレーの部分のサーフェスを作成
white_vol = isosurface(Ds,2.5);
gray_vol  = isosurface(Ds,1.5);

% 可視化
h = figure('visible','off','outerposition',[0 0 800 600],'renderer','openGL');
patch(white_vol,'FaceColor','b','EdgeColor','none');
patch(gray_vol,'FaceColor','y' ,'EdgeColor','none',...
  'FaceAlpha',0.5);
view(45,15); daspect(1./voxel_size2); axis tight;axis off;
camlight; camlight(-80,-10); lighting phong;
movegui(h, 'center');
set(h,'visible','on');

%% 体積計算
stats2 = regionprops3(Ds,'Volume');
Volsize = sum(stats2.Volume)

%% ボリュームビューワーで確認
volshow(Ds,'ScaleFactors',[1 2 1]);shg

%% 終了

%%
% Copyright 2018-2020 The MathWorks, Inc.