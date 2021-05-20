%% RAWファイルからのRGB画像作成パイプライン
%% RAWファイル読込み
fileName = "colorCheckerTestImage.NEF";
cfaImage = rawread(fileName);
imshow(cfaImage,[]);
title("Linear CFA Image");

%% メタデータの読込み
fileInfo = rawinfo(fileName)
%% CFA画像の線形化
% ルックアップテーブルにしたがって、数値を線形化します。
% rawread関数で読み込んだ段階で自動的に線形化済みとなります。
% ここでは、線形化に使ったルックアップテーブルを表示します。
linTable = fileInfo.ColorInfo.LinearizationTable;
plot((0:length(linTable)-1), fileInfo.ColorInfo.LinearizationTable) 
title("Linearization Table")
%% 画像のスケーリング 
% ブラックレベル
blackLevel = fileInfo.ColorInfo.BlackLevel

if isvector(fileInfo.ColorInfo.BlackLevel)
    cfaMultiChannel = performPerChannelBlackLevelSub(cfaImage, fileInfo);
else
    cfa = performRegionBlackLevelSub(cfaImage, fileInfo);
    % CFA画像をチャンネル毎に別レイヤとしたマルチレイヤ画像に変換する
    cfaMultiChannel = raw2planar(cfa);
end
% ブラックレベル以下をゼロに
cfaMultiChannel( cfaMultiChannel < 0 ) = 0;
cfaMultiChannel = double(cfaMultiChannel);
% ホワイトレベル
whiteLevel = max(cfaMultiChannel(:))
scaledCFAMultiChannel = cfaMultiChannel ./ whiteLevel;
%% ホワイトバランス調整
% メタデータの取り出し
camWB = fileInfo.ColorInfo.CameraAsTakenWhiteBalance;
gLoc = strfind(fileInfo.CFALayout,"G"); 
gLoc = gLoc(1);
camWB = camWB/camWB(gLoc)
wbMults = reshape(camWB,[1 1 numel(camWB)]);
wbCFAMultiChannel = scaledCFAMultiChannel .* wbMults;
% 元のCFA画像形式に戻す
cfaWB = planar2raw(wbCFAMultiChannel);
cfaWB = im2uint16(cfaWB);
%% デモザイクと回転補正
camspaceRGB = demosaic(cfaWB,fileInfo.CFALayout);
camspaceRGB = imrotate(camspaceRGB,fileInfo.ImageSizeInfo.ImageRotation);
imshow(camspaceRGB)
title("Rendered Image in Linear Camera Space");
%% RGB画像への変換
srgbImageLinear = imapplymatrix(fileInfo.ColorInfo.CameraTosRGB, camspaceRGB,"uint16");
% sRGB空間にガンマ補正を施す
srgbImage = lin2rgb(srgbImageLinear);
imshow(srgbImage)
title("Rendered RGB Image in sRGB Colorspace")

%% サポート関数
function cfa = performPerChannelBlackLevelSub(cfa, fileInfo)
    % Transforms an interleaved CFA into an (M/2-by-N/2-by-4) array, where
    % each plane corresponds to a specific color channel.
    
    % This transformation simplifies pipeline implementation
    cfa = raw2planar(cfa);
    
    blackLevel = fileInfo.ColorInfo.BlackLevel;
    blackLevel = reshape(blackLevel,[1 1 numel(blackLevel)]);
    
    cfa = cfa - blackLevel;
end

function cfa = performRegionBlackLevelSub(cfa,fileInfo)
    % The m-by-n black-level must be repeated periodically across the entire image 
    repeatDims = fileInfo.ImageSizeInfo.VisibleImageSize ./ size(fileInfo.ColorInfo.BlackLevel);
    blackLevel = repmat(fileInfo.ColorInfo.BlackLevel, repeatDims);
    
    cfa = cfa - blackLevel;
end

function cam2xyz = computeXYZTransformation(fileInfo)
    % The CameraToXYZ matrix imposes an RGB order i.e 
    % [X, Y, Z]' = fileInfo.ColorInfo.CameraToXYZ .* [R, G, B]'.
    
    % However, the order of values for white balance mutlipliers are as per
    % fileInfo.CFALayout. Hence, we have to reorder the multipliers to
    % ensure we are scaling the correct row of the CameraToXYZ matrix.
    wbIdx = strfind(fileInfo.CFALayout,"R");
    gidx = strfind(fileInfo.CFALayout,"G"); wbIdx(2) = gidx(1); 
    wbIdx(3) = strfind(fileInfo.CFALayout,"B");
    
    wbCoeffs = fileInfo.ColorInfo.D65WhiteBalance(wbIdx);
    
    cam2xyz = fileInfo.ColorInfo.CameraToXYZ ./ wbCoeffs;
end

% Copyright 2021 The MathWorks, Inc.