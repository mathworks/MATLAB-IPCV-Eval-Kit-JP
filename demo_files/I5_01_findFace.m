%% コンピュータビジョンデモ：顔認識
% 画像データをロード
I = imread('visionteam.jpg');
figure; imshow(I);

%% 物体認識オブジェクトの定義、実行 [２行のMATLABコード]
%     顔認識用のトレーニングされたデータは内蔵
detector = vision.CascadeObjectDetector();
faces = step(detector, I)

%% 検出された顔の位置に、四角い枠とテキストを追加
I2 = insertObjectAnnotation(I, 'rectangle', faces, [1:size(faces,1)], 'FontSize',18);
figure; imshow(I2);

release(detector);

%% 
% Copyright 2014 The MathWorks, Inc.

