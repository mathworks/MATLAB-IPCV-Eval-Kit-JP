clear;clc;close all;imtool close all

%% �摜�̓Ǎ���
I = imread('I5_03_1_ocr\IMG_2537_stop.JPG');
figure;imshow(I);

%% �O���[�X�P�[���摜�֕ϊ�
G = rgb2gray(I);
figure;imshow(G);

%% �����t�H���W�[�����ŁA���̕����݂̂��c��
G2 = imbothat(G, ones(13));   imshow(G2); %�����������c���FClose - ����
G3 = imbinarize(G2,graythresh(G2));imshow(G3); %��l��
G4 = imopen(G3, ones(5));     imshow(G4); %�ׂ���������
G5 = bwareaopen(G4,200);                  %���������݂�����
imshow(G5);
     
%% �����F��
results = ocr(G5, 'Language','Japanese')

%% ���ʂ�\��
I1 = insertShape(I, 'Rectangle', results.WordBoundingBoxes, 'LineWidth', 3);
figure;imshow(I1);
text(results.WordBoundingBoxes(1), results.WordBoundingBoxes(2)-50, results.Words(1),'FontSize',12,'BackgroundColor',[1 1 0]);


%% �ǂݏグ (���{�ꉹ�������G���W���͕ʓr����v)
NET.addAssembly('System.Speech');   %.NET�A�Z���u���̓Ǎ���
speak = System.Speech.Synthesis.SpeechSynthesizer;
speak.Volume = 100;
speak.SelectVoice('������');

speak.Speak([results.Words{1} ' ���ĉ�����']);


%% �ǂݏグ (�p�ꉹ�������G���W����Windows�ɕt��)
NET.addAssembly('System.Speech');   %.NET�A�Z���u���̓Ǎ���
speak = System.Speech.Synthesis.SpeechSynthesizer;
speak.Volume = 100;
speak.Speak('stop');


%% �I��











%% ���{��̓ǂݏグ�ɂ́A�ʓr���{�ꉹ�������G���W�����K�v
%  �p��Ɋւ��Ă�Windows�ɓ���

%% ocr���s�O�ɁA�֐�������Otu�@�ɂ��2�l������Ă��܂�
%G = rgb2gray(I);imtool(im2bw(G,graythresh(G)))

% Copyright 2014 The MathWorks, Inc.
