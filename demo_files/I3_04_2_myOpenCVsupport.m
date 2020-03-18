%% OpenCV の インターフェースを持った Cの関数を、
%     MATLABからコールするためのサポートパッケージ
%   （R2014b：Computer Vision System Toolboxの新機能）
%  説明ビデオ：http://jp.mathworks.com/videos/using-opencv-with-matlab-106409.html

%% サポートパッケージのインストール
% 下記コマンドを実行し、OpenCV Interface    をインストール
visionSupportPackages

%% サポートパッケージがインストールされたディレクトリを確認
fileLoc = which('mexOpenCV.m')
winopen(fileLoc(1:end-12));    % ディレクトリを開く

% ディレクトリ内の、README.txt  を確認
% 特に、必要なCコンパイラに注意
% 例題は、example ディレクトリ内

%% C++用のコンパイラの設定の確認
%  現れた選択から、上記のREADME.txtに書かれているコンパイラを選択
mex -setup c++

%% 現在のフォルダにexampleフォルダをコピー
copyfile([fileLoc(1:end-12) '\example'], 'OpenCV_example_copy')

%% TemplateMatching の例題フォルダへ移動
cd OpenCV_example_copy\TemplateMatching

%% 用意されている、matchTemplateOCV.cpp をラッパーとして、MEXファイルへコンパイル
edit matchTemplateOCV.cpp        % ラッパーの内容を確認
%% mexOpenCV 関数を用いコンパイル（C++をコンパイルし、OpenCVのライブラリとリンク）
mexOpenCV matchTemplateOCV.cpp   %  matchTemplateOCV.mexw64 もしくは .mexw32 が生成される

%% 生成されたMEXファイルの動作を確認
%     ラッパーファイルの名前で呼び出す
edit testMatchTemplate           % テストベンチを確認（matchTemplateOCV としてコール）

%%
% TemplateMatchingの例題：永続メモリをMEX内でどのように取り扱うかの例
cd ..\ForegroundDetector

%% 用意されている APIの一覧を確認
edit([matlabroot '\extern\include\opencvmex.hpp']);

%% 終了




% ラッパーファイルの内容について
%    #include "opencvmex.hpp"      ：このサポートパッケージで提供される全APIを宣言
%    ラッパーの関数名･引数は定型のものを使用：関数の名前は mexFunction
%    mxArray はMATLABで使われる使われるデータ型、cv::MATは、OpenCVで使われるデータ型

%% Copyright 2015 The MathWorks, Inc.

