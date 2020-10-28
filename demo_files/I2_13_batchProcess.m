function out = I2_13_batchProcess(im)
% バッチ処理で用いる画像処理のサンプルスクリプト
out.orig   = im;
out.th     = graythresh(im);    % 2値化用の閾値を求める
out.result = imbinarize(im, out.th);     % 2値化の実行
end
% Copyright 2015 The MathWorks, Inc.
