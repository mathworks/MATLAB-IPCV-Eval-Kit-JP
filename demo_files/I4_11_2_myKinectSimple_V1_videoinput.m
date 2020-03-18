%% Using the Kinect(R) for Windows(R) V1 from Image Acquisition Toolbox(TM)
clear all; close all; clc; imaqreset;
initMag = iptgetpref('ImshowInitialMagnification');
iptsetpref('ImshowInitialMagnification','fit');
vWidth  = 640;
vHeight = 480;

%% GUI Settings *******************************
% Skelton/Stop Button
a=true;
sz = get(0,'ScreenSize');
figure('MenuBar','none','Toolbar','none','Position',[15 sz(4)-120 100 80]);
hStop=uicontrol('Style', 'pushbutton', 'String', 'Stop', ...
                'Position', [20 20 80 40], 'Callback', 'a=false;');

% figure definition (1st row)
cmap = colormap(jet(16));
figHSize=300;
figVSize=225;
pos=[150 sz(4)-figVSize-30 figHSize figVSize];
viewerRGB = vision.DeployableVideoPlayer('Name','RGB Image',        'Location',pos(1:2), 'Size','Custom', 'CustomSize',[figHSize figVSize]);
pos(1) = pos(1)+figHSize+20;
viewerSeg = vision.DeployableVideoPlayer('Name','Segmented People', 'Location',pos(1:2), 'Size','Custom', 'CustomSize',[figHSize figVSize]);
pos(1) = pos(1)+figHSize+20;
viewerDep = vision.DeployableVideoPlayer('Name','Depth Image',      'Location',pos(1:2), 'Size','Custom', 'CustomSize',[figHSize figVSize]);

% Depth Plot: Vertical Position Setting Slider
pos(1) = pos(1)+figHSize+20; pos(2) = pos(2)-50;
sliderVPos=uint16(vHeight/2);
figure('MenuBar','none','Toolbar','none','Position',[pos(1:2) 120 280]);  
hSlider = uicontrol('Style', 'slider', 'Min', 0, 'Max', 479, ...
        'Position', [60 20 20 200], 'Value', sliderVPos, 'SliderStep',[0.01 0.1], ...
        'Callback', 'sliderVPos=uint16(vHeight-get(hSlider,''Value''));');
uicontrol('Style', 'text', 'String', {'V Pos of ';'Depth Image'}, ...
        'Position', [20 230 100 35]);

% figure definition (2nd row)
pos=[150 sz(4)-figVSize-100-figVSize-25 figHSize figVSize];
pos(1) = pos(1)+figHSize+20;
viewerOC = vision.DeployableVideoPlayer('Name','Optical Camouflage', 'Location',pos(1:2), 'Size','Custom', 'CustomSize',[figHSize figVSize]);
pos(1) = pos(1)+figHSize+20;
fp=figure('Position', pos);    % Depth Plot

% Display Tilt-angle Slider
depthSrc.CameraElevationAngle = 0;
figure('MenuBar','none','Toolbar','none','Position',[15 sz(4)-450 120 280]);  
hTilt = uicontrol('Style', 'slider', 'Min', -27, 'Max', 27, ...
        'Position', [60 20 20 200], 'Value', 0, 'SliderStep',[0.01 0.1], ...
        'Callback', 'depthSrc.CameraElevationAngle = get(hTilt,''Value'');');
uicontrol('Style', 'text', 'String', {'Kinect ';'Tilt Angle'}, ...
        'Position', [35 230 80 32]);

% Start timer to calculate frame rate
tic;
cnt = 1;
fps = single(0.0);

%% Kinect Settings ************************
colorVid = videoinput('kinect',1);          %video input object for RGB (640 x 480)
depthVid = videoinput('kinect',2);          %video input object for depth
depthSrc = getselectedsource(depthVid);     %video source object for depth
depthSrc.TrackingMode = 'Skeleton';         % Turn on Skeleton Tracking
depthSrc.BodyPosture  = 'Standing';         % Standing (20joints) or Seated (10joints)

% Use manual trigger to synchronize RGB and depth image
triggerconfig([colorVid depthVid], 'manual');
set([colorVid depthVid], 'FramesPerTrigger', 1);
set([colorVid depthVid], 'TriggerRepeat', Inf);
start([colorVid depthVid]);     % start device

%% Main Loop ***************
while (a)
%for ii=1:200
    [colorFrameData] = getsnapshot(colorVid);
    [depthFrameData depthMetaData] = getsnapshot(depthVid);
    
    trackedSkeletons = find(depthMetaData.IsSkeletonTracked);  % non-0 element index
    jointIndices = depthMetaData.JointImageIndices(:, :, trackedSkeletons);
    nSkeleton = length(trackedSkeletons);                      % # of skelton being tracked
    I4_11_2_my_util_skeletonViewer_V1(viewerRGB, jointIndices, colorFrameData, nSkeleton);   % çúäiÇï\é¶
     
    % Display Segmented people
    SegRGB = label2rgb(depthMetaData.SegmentationData, 'jet(16)','k');
    step(viewerSeg, SegRGB);
    
    % Display Depth Image (uint16 : unit=mm)
    Idep = imadjust(depthFrameData);
    Idep = insertShape(Idep, 'Line', [1 sliderVPos vWidth sliderVPos], 'Color','red', 'Opacity',1, 'LineWidth',5);    
    step(viewerDep, Idep);
    
    % Display Depth Plot
    set(0,'CurrentFigure',fp);
    plot(int32(depthFrameData(sliderVPos,:)));
    axis tight; title('Depth Plot at the red line');
    
    drawnow limitrate;

    
   % Frame rate calculation from averaging 30 frame
   cnt = cnt + 1;
   if (mod(cnt,30) == 0)
    t = toc;
    fps = single(30/t);
    tic;
   end

end

%%
stop([colorVid depthVid]);     % Stop the Device
delete(colorVid);
delete(depthVid);
iptsetpref('ImshowInitialMagnification', initMag);   % Revert to orig setting
imaqreset;


%      jointCoordinate = depthMetaData.JointWorldCoordinates(:, :, trackedSkeletons);
%      set(0,'CurrentFigure',f3);
%      plot3(jointCoordinate(:,1), jointCoordinate(:,2), jointCoordinate(:,3), '+');


% [Note] 
% if the 'BodyPosture' property is set to 'Seated', the 'JointCoordinates' and 'JointIndices'
% will still have a length of 20, but indices 2-11(upper-body joints) alone will be populated.
%
% IsSkeletonTracked : tracked state of each of the six skeletons.
% IsPositionTracked : tracking of the position of each of the six skeletons.
% JointImageIndices : [x, y] in color image
% JointWorldCoordinates : x-, y- and z-coordinates for 20 joints, in meters from the sensor
%    Hip_Center = 1;
%    Spine = 2;
%    Shoulder_Center = 3;
%    Head = 4;
%    Shoulder_Left = 5;
%    Elbow_Left = 6;
%    Wrist_Left = 7;
%    Hand_Left = 8;
%    Shoulder_Right = 9;
%    Elbow_Right = 10;
%    Wrist_Right = 11;
%    Hand_Right = 12;
%    Hip_Left = 13;
%    Knee_Left = 14;
%    Ankle_Left = 15;
%    Foot_Left = 16; 
%    Hip_Right = 17;
%    Knee_Right = 18;
%    Ankle_Right = 19;
%    Foot_Right = 20;
%
% 
% [meta Data from depth channel]             % max number of skelton is 2
% 10x1 struct array with fields:
%     AbsTime: [1x1 double]
%     FrameNumber: [1x1 double]
%     IsPositionTracked: [1x6 logical]       % for 6 persons
%     IsSkeletonTracked: [1x6 logical] 
%     JointImageIndices: [20x2x6 double]     % x,y axis
%     JointTrackingState: [20x6 double]
%     JointWorldCoordinates: [20x3x6 double]
%     PositionImageIndices: [2x6 double]
%     PositionWorldCoordinates: [3x6 double]
%     RelativeFrame: [1x1 double]
%     SegmentationData: [640x480 double]    % 0~6
%     SkeletonTrackingID: [1x6 double]
%     TriggerIndex: [1x1 double]

%    For segmented image, imshow is used instead of imagesc to keep aspect ratio.

%  Copyright 2014-2016 The MathWorks, Inc.
