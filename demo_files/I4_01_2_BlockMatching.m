%% Read in an image, convert it to grayscale, and translate it to create second image.
img = imread('onion.png');

img1 = im2double(rgb2gray(img));
htran = vision.GeometricTranslator('Offset', [5 5], ...
 		'OutputSize', 'Same as input image');
hbm = vision.BlockMatcher( ...
 		'ReferenceFrameSource','Input port','BlockSize',[35 35]);
hbm.OutputValue = ...
 		'Horizontal and vertical components in complex form';
halphablend = vision.AlphaBlender;

%% Offset the first image by [5 5] pixels to create second image.
img2 = step(htran, img1);

%% Compute motion of the two images.
motion = step(hbm, img1, img2);

%% Blend two images.
img12 = step(halphablend, img2, img1);

%% Show the directions.
[X Y] = meshgrid(1:35:size(img1, 2), 1:35:size(img1, 1));
imshow(img12); hold on;
quiver(X(:), Y(:), real(motion(:)), imag(motion(:)), 0); hold off;

%%
% Copyright 2014 The MathWorks, Inc.
