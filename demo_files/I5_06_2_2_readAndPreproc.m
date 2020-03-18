function Iout = I5_06_2_2_readAndPreproc( inFilename )
    % 画像の読込み
    I = imread(inFilename);
    
    % グレースケールの場合にRGBへ変換
    if ismatrix(I)          % 1次元もしくは2次元の場合に真
        I = repmat(I, [1,1,3]);
    end
    
    % 画像の縦横を、227x227ピクセルへ リサイズ （縦横比を保つ）
    if size(I, 1) > size(I, 2)
      I1 = imresize(I, [227, NaN]);
      Iout = padarray(I1, [0, 227-size(I1, 2)], 0, 'pre');
    else
      I1 = imresize(I, [NaN, 227]);
      Iout = padarray(I1, [227-size(I1, 1), 0], 0, 'pre');
    end

end


% Copyright 2018 The MathWorks, Inc.