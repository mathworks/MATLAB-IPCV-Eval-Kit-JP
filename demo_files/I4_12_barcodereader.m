%% QRコードの読み取り

% QRコード画像の読み込み
I = imread("barcodeQR.jpg");

% QRコードの読み取り
[msg, ~, loc] = readBarcode(I);

% デコードしたメッセージを挿入
xyText =  loc(2,:);
Imsg = insertText(I, xyText, msg, "BoxOpacity", 1, "FontSize", 40);

% 検出したファインダーパターンの挿入
Imsg = insertShape(Imsg, "FilledCircle", [loc, ...
    repmat(10, length(loc), 1)], "Color", "red", "Opacity", 1);

% 可視化による確認
imshow(Imsg)


%% バーコード画像の読み込み
I = imread("barcode1D.jpg");

% バーコードの読み取り
[msg, format, locs] = readBarcode(I);

% 検出したバーコードの形式およびメッセージを挿入
I = insertText(I,[0 0],[format+", "+msg],'FontSize',40);

% スキャンしたラインを表示の挿入
xyBegin = locs(1,:); imSize = size(I);
I = insertShape(I,"Line",[1 xyBegin(2) imSize(2) xyBegin(2)], ...
    "LineWidth", 7);

% マーカーの挿入
I = insertShape(I, "FilledCircle", [locs, ...
    repmat(10, length(locs), 1)], "Color", "red", "Opacity", 1);
 
% 可視化による確認
imshow(I)

%% Copyright 2020 The MathWorks, Inc.