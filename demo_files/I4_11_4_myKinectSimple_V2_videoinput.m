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

% Start timer to calculate frame rate
tic;
cnt = 1;
fps = single(0.0);

%% Kinect Settings ************************
colorVid = videoinput('kinect',1);          %video input object for RGB (640 x 480)
depthVid = videoinput('kinect',2);          %video input object for depth
depthSrc = getselectedsource(depthVid);     %video source object for depth
depthSrc.EnableBodyTracking = 'on';         % Turn on Skeleton Tracking

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
    
    trackedSkeletons = find(depthMetaData.IsBodyTracked);  % non-0 element index
    jointIndices = depthMetaData.JointPositions(:, [1:2], trackedSkeletons);
    nSkeleton = length(trackedSkeletons);                      % # of skelton being tracked

    % Display RGB image
    step(viewerRGB, colorFrameData);
    
    % Display Segmented people
    SegRGB = label2rgb(depthMetaData.BodyIndexFrame, 'jet(256)','k');
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


% [Note] 
% IsBodyTracked : tracked state of each of the six skeletons.
% [Joint Position]‚“
%   SpineBase = 1;
%   SpineMid = 2;
%   Neck = 3;
%   Head = 4;
%   ShoulderLeft = 5;
%   ElbowLeft = 6;
%   WristLeft = 7;
%   HandLeft = 8;
%   ShoulderRight = 9;
%   ElbowRight = 10;
%   WristRight = 11;
%   HandRight = 12;
%   HipLeft = 13;
%   KneeLeft = 14;
%   AnkleLeft = 15;
%   FootLeft = 16; 
%   HipRight = 17;
%   KneeRight = 18;
%   AnkleRight = 19;
%   FootRight = 20;
%   SpineShoulder = 21;
%   HandTipLeft = 22;
%   ThumbLeft = 23;
%   HandTipRight = 24;
%   ThumbRight = 25;
% 
% [meta Data from depth channel]             % max number of skelton is 6
%         BodyIndexFrame: [424x512 double]
%         BodyTrackingID: [0 0 0 0 0 0]
%     HandLeftConfidence: [1 1 1 1 1 1]
%          HandLeftState: [1 1 1 1 1 1]
%    HandRightConfidence: [1 1 1 1 1 1]
%         HandRightState: [1 1 1 1 1 1]
%          IsBodyTracked: [0 0 0 0 0 0]
%         JointPositions: [25x3x6 double]
%     JointTrackingState: [25x6 double]


%  Copyright 2016 The MathWorks, Inc.
