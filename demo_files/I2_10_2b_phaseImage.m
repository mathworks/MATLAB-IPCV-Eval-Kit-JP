%% ÊæÌ¶¬
clear;clc;close all;imtool close all

%% æÌÇÝ
G = imread('coins.png');
figure;imshow(G);

%% 2³ÌFFTvZF¶ã÷ª[ügW(DC¬ª)
F = fft2(G);
figure;imshow(log(abs(F)), []);colormap(jet); colorbar;    % DC¬ªª¶ã÷

%% fftshiftÖðp¢A[ügW(DC¬ª)ð¶ã÷©çASÖÚ®
%     æêÛÀÆæOÛÀAæñÛÀÆælÛÀðüêÖ¦
Fs = fftshift(F);
figure;imshow(log(abs(Fs)), []);colormap(jet); colorbar;

%% e¬ªlðUÅ³K» (SÄÌüg¬ªª¯¶U)
Fn = F ./ abs(F);

%% tt[GÏ·
Gr = ifft2(Fn);
figure; imshow(Gr, []);

%% I¹









%%
% Copyright 2015 The MathWorks, Inc.


