clear;clc;close all;imtool close all

%% ���̂̒�ʕ]���i�ʐϥ���S�_����a����͒��j
I = imread('coins.png');        % �摜�̓Ǎ�
figure; imshow(I);              % �\��

figure; imhist(I);              % �q�X�g�O�����\��
Ibw = I>100;                    % �����̉摜�֕ϊ�
figure; imshow(Ibw);            % �\��
Ibw = I>90;                     % �Θb�I�T��
figure; imshow(Ibw);            % �\��

Ibwf = imfill(Ibw, 'holes');    % ���𖄂߂�
figure; imshow(Ibwf);           % �\��

Ibwc = bwareaopen(Ibwf, 10);    % ���݂̏���  (10�s�N�Z���ȉ��̂���)
figure; imshow(Ibwc);           % �\��        [�Θb�I�ȒT��]

%% �e�̈�̖ʐρE���S�_�E���a�E���͒������߂�
stats = regionprops('table', Ibwc, 'Area', 'Centroid', 'MajorAxisLength', 'Perimeter')   % struct/table

areas = stats.Area           % �e�X�̖ʐ�

mean(areas)                     % �ʐς̕���

figure;histogram(areas);             % �ʐς̃q�X�g�O�����\��

figure;imshow(I);improfile     % �����ɉ������s�N�Z���l�F2�_���}�E�X�E�N���b�N�Ŏw�肵���^�[��

figure; surf(double(I));shading interp;  % 3�����\��(��]��)�F�c�[�����j���[����"3������]"
%%




%%   ���̒�ʕ]���̌��ʂ��摜��ɏ�����
I1 = insertMarker(I, stats.Centroid, 'star', 'Color','red');
I2 = insertText(I1, stats.Centroid,  cellstr(num2str(areas)), 'BoxOpacity',0, 'FontSize',10);
I3 = insertText(I2, [160, 220], ['# of coins: ' num2str(size(stats, 1))], 'FontSize',16);
figure; imshow(I3);
hold on;
visboundaries(Ibwc, 'Color','g');
hold off;

%% �I��





%% �G�b�W���o
I = imread([matlabroot '\toolbox\coder\codegendemos\coderdemo_edge_detection\hello.jpg']);
figure;imshow(I);
G = rgb2gray(I);
figure;imshow(G);
Gcanny = edge(G,'canny',0.18);        % �G�b�W���o�F�L���j�[�@
figure;imshow(Gcanny);


%% �~�̌��o
RGB = imread('tape.png');        % �Z���e�[�v�̉摜
figure;imshow(RGB);
[center, radius] = imfindcircles(RGB,[60 100],'Sensitivity',0.9)  %�~�̌��o
viscircles(center,radius);      % �~�̕\��
hold on; plot(center(:,1),center(:,2),'yx','LineWidth',4); hold off;


%% ���ω��t�B���^�[����
Fave=fspecial('average');           % �t�B���^�[�W������
Iave=imfilter(I, Fave);             % �t�B���^�[����
I=[I Iave];                         % �E���ɕʂ̉摜���g��
figure; imshow(I);                  % �\��

%% �N��������
Ish=imsharpen(Iave, 'Amount', 3);        % �t�B���^�[�����A���x
figure; imshowpair(Iave, Ish, 'montage'); % �����щ���

fspecial('average')
fspecial('average', 5)
edit fspecial      % fspecial�֐��̎����\�� or �֐��I���F4
doc                % �[�������h�L�������g
%% �I��












%% [�Q�l]
% 臒l�������I�ɋ��߂�֐�
Th = graythresh(I)              % ��Ö@���g���ĉ摜�̓�l���p臒l�����߂�
Ibw = imbinarize(I, Th);             % ���߂�臒l��p���ĉ摜�̓�l��
figure; imshow(Ibw);            % �摜�̕\��



doc                             % �h�L�������g���J��
edit imfill                     % M����ŏ�����Ă���֐��������̂Ŏ�������m�F���������܂�
edit bwareaopen


% Copyright 2014 The MathWorks, Inc.
