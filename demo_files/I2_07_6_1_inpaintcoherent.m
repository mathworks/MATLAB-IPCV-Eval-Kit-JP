%% ζΜCiCyCeBOEsv¨Μj

%% ζΗέέΖΒ»
I = imread('coloredChips.png');
figure
imshow(I,[])

%% CΣπ~Εwθ
h = drawcircle('Center',[130,42],'Radius',40);
numRegion = 6;
roiCenter = [130 42;433 78;208 108;334 124;434 167;273 58];
roiRadius = [40 50 40 40 40 30];
roi = cell([numRegion,1]);
for i = 1:numRegion
    c = roiCenter(i,:);
    r = roiRadius(i);
    h = drawcircle('Center',c,'Radius',r);
    roi{i} = h;
end

%% createMaskΦΕwθ΅½ROIΜ}XNπΆ¬
mask = zeros(size(I,1),size(I,2));
for i = 1:numRegion
    newmask = createMask(roi{i});
    mask = xor(mask,newmask);
end
% Β»
montage({I,mask});
title('COζ vs CΣΜ}XNζ');

%% YΣΜζC
J = inpaintCoherent(I,mask,'SmoothingFactor',0.5,'Radius',1);
montage({I,J});
title('COζ vs Cγζ');

%% 
% Copyright 2019 The MathWorks, Inc.