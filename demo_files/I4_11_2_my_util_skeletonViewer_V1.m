function [] = my_util_skeletonViewer(viewer, skeleton, image, nSkeleton)
% Displays one RGB image frame with skeleton joint locations overlayed
% skeleton: A 20x2x1 or 20x2x2 skeleton joint image locations returned by the
% Kinect for Windows
% image: The RGB image corresponding to the skeleton frame.
% nSkeleton: Number of Skeletons
%
%  Copyright 2014 The MathWorks, Inc.
%         modified by Masa Otobe (masa.otobe@mathworks.co.jp)

% Here is the order of joints returned by Kinect for Windows
%     HipCenter = 1;
%     Spine = 2;
%     ShoulderCenter = 3;
%     Head = 4;
%     ShoulderLeft = 5;
%     ElbowLeft = 6;
%     WristLeft = 7;
%     HandLeft = 8;
%     ShoulderRight = 9;
%     ElbowRight = 10;
%     WristRight = 11;
%     HandRight = 12;
%     HipLeft = 13;
%     KneeLeft = 14;
%     AnkleLeft = 15;
%     FootLeft = 16; 
%     HipRight = 17;
%     KneeRight = 18;
%     AnkleRight = 19;
%     FotoRight = 20;


% Skeleton connection map to link the joints
SkeletonConnectionMap = [[1 2];
                         [2 3];
                         [3 4];
                         [3 5];
                         [5 6];
                         [6 7];
                         [7 8];
                         [3 9];
                         [9 10];
                         [10 11];
                         [11 12];
                         [1 17];
                         [17 18];
                         [18 19];
                         [19 20];
                         [1 13];
                         [13 14];
                         [14 15];
                         [15 16]];
 
Pos1 = zeros(19,4);
Pos2 = zeros(19,4);
% RGB画像内に、スケルトンを上書き
if nSkeleton > 0
  for i = 1:19
    Pos1(i,:) = [skeleton(SkeletonConnectionMap(i,1),1,1) skeleton(SkeletonConnectionMap(i,1),2,1) ...
                 skeleton(SkeletonConnectionMap(i,2),1,1) skeleton(SkeletonConnectionMap(i,2),2,1)];
  end
    image = insertShape(image, 'Line', Pos1, 'Color', 'red', 'LineWidth',5);
    image = insertShape(image, 'FilledCircle', [skeleton(:,:,1) linspace(8,8,20)'], 'Color', 'red');
end

if nSkeleton > 1
  for i = 1:19     
    Pos2(i,:) = [skeleton(SkeletonConnectionMap(i,1),1,2) skeleton(SkeletonConnectionMap(i,1),2,2) ...
                 skeleton(SkeletonConnectionMap(i,2),1,2) skeleton(SkeletonConnectionMap(i,2),2,2)];     
  end
    image = insertShape(image, 'Line', Pos2, 'Color', 'green', 'LineWidth',5);
    image = insertShape(image, 'FilledCircle', [skeleton(:,:,2) linspace(8,8,20)'], 'Color', 'green');
end
 
% 画像を表示
step(viewer, image);

