function out = I2_13_batchProcess(im)
% �o�b�`�����ŗp����摜�����̃T���v���X�N���v�g
out.orig   = im;
out.th     = graythresh(im);    % 2�l���p��臒l�����߂�
out.result = imbinarize(im, out.th);     % 2�l���̎��s
end
% Copyright 2015 The MathWorks, Inc.
