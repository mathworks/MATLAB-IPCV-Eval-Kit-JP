function out = myfilter(imWaterMask)
%#codegen
coder.gpu.kernelfun

%% ガウシアンフィルタで画像をぼかす
blurH = fspecial('gaussian',20,5);
out = imfilter(single(imWaterMask)*10, blurH);

end

%% 
% Copyright 2019 The MathWorks, Inc.