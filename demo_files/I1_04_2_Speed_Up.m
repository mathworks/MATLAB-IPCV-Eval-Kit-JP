clc;close all;imtool close all;clear;

%% 配列の事前割り当てなし（低速）
%    ループの中で変数xの要素の数がだんだん大きくなる
clear
tic
for n = 1:1e7
  x(n) = n;
end
toc

%% 配列の事前割り当て（高速）
clear
x = zeros(1e7,1);
tic
for n = 1:10000000
  x(n) = n;
end
toc

%% 要素をスキャンする:横方向 （低速）
%    4000x4000の行列の、要素が0.5以上の場所をtrueにする
clear
X = rand(4000);
Y = false(4000);
tic
for r = 1:4000 % 行
    for c = 1:4000 % 列
        if X(r, c) > 0.5
            Y(r, c) = true;
        end
    end
end
toc

%% 縦方向に要素をスキャンする（速い）
clear
X = rand(4000);
Y = false(4000);
tic
for c = 1:4000 % 列
    for r = 1:4000 % 行
        if X(r, c) > 0.5
            Y(r, c) = true;
        end
    end
end
toc

%% 配列で処理 (より高速)
clear
X = rand(4000);
Y = false(4000);
tic
  Y = X > 0.5;
toc

%% Copyright 2015 The MathWorks, Inc.

