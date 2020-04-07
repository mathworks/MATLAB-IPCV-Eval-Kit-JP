%% ���E�{�b�N�X�f�[�^�̊g��

%% �摜�̓Ǎ���
I = imread('peppers.png');

%% ���E�{�b�N�X�̒�`
bboxA = [
    410 230 100 90
    186 78  80  60
    ]

labelsA = [
    "garlic"
    "onion"
    ];

%% �摜�Ƌ��E�{�b�N�X�̃��T�C�Y(1.5x)
scale = 1.5; 
J = imresize(I,scale); 
bboxB = bboxresize(bboxA,scale); 

figure
I = insertObjectAnnotation(I,'Rectangle',bboxA,labelsA);
J = insertObjectAnnotation(J,'Rectangle',bboxB,labelsA);
imshowpair(I,J,'montage')

%% �摜�Ƌ��E�{�b�N�X�̊􉽊w�I�ϊ�(���]�ƈړ��j
tform = affine2d([-1 0 0; 0 1 0; 50 50 1]);
rout = affineOutputView(size(I),tform);
J = imwarp(I,tform,'OutputView',rout);
[bboxB,indices] = bboxwarp(bboxA,tform,rout);
labelsB = labelsA(indices);
annotatedI = insertObjectAnnotation(I,'Rectangle',bboxA,labelsA);
annotatedJ = insertObjectAnnotation(J,'Rectangle',bboxB,labelsB);
figure
montage({annotatedI, annotatedJ})

%% �摜�Ƌ��E�{�b�N�X�̐؂蔲��(256x256�ɐ؂蔲��)
targetSize = [256 256];
win = centerCropWindow2d(size(I),targetSize);
[r,c] = deal(win.YLimits(1):win.YLimits(2),win.XLimits(1):win.XLimits(2));
J = I(r,c,:);
[bboxB,indices] = bboxcrop(bboxA,win);
labelsB = labelsA(indices);
figure
I = insertObjectAnnotation(I,'Rectangle',bboxA,labelsA);
J = insertObjectAnnotation(J,'Rectangle',bboxB,labelsB);
imshowpair(I,J,'montage')

%%
% _Copyright 2019 The MathWorks, Inc._