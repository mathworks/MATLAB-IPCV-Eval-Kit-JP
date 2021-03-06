% This is a simple script for introduction to image processing with MATLAB

%% MATLABによる画像処理の基本操作
%    少ない記述量
%    一行･一行、対話的な処理方法探索
%    可視化･デバッグの容易さ

% GUIの説明
        % MATLABを立ち上げると、このような画面で立ち上がります。
        % ここでは文字を大きくお見せするために、
        % コマンドウインドウ以外をすべて最小化して、
        % ツールストリップも最小化します。

%%
2+3     %[インタプリタ] MATLABはインタプリタ型の言語ですので、
        % このようにリターンキーを押すことで結果をすぐに見ることができます。

a=2+3   % 変数定義不要
        % ワークスペース確認。デフォルトの方はdouble
        % コマンド履歴確認

a=2+3;  % セミコロンを付けると結果の表示がされません。

%% 行列操作による画像の取扱い
magic(5)      % 先ず、5行5列の行列を生成します。
              % ここでは、magicという関数を用い、
              % １から25の数を一回ずつ使い、縦・横・斜めどこを足し合わせても、
              % 同じ数になる、魔方陣という行列を生成してみます。
              
%% 次に、この行列を変数Aに代入したいと思います。
A=magic(5)    % [定義不要] MATLABでは、C等のような変数の定義が必要ありませんので、
              % このように、変数Aに代入することで変数が自動的に作成されます。
              
%% 次にこの行列を画像として表示したいと思います。
              % 他の言語ですと、例えばBitmap形式のヘッダーを生成して
              % 画面の左下から右上へピクセルデータをFileへ書き出したのちに、
              % 別ツールで表示したりするかもしれませんが、
              % MATLABには、[可視化用の様々な関数]が用意されています。
              % ここではimshowという関数を用いて表示したいと思います。 
              % 1が真っ黒・最大値の25が真っ白として表示します。
imshow(A, []);
        % このように画像が表示されますが、
        % 行列のそれぞれの要素の値が、各Pixelの明るさに対応していて、
        % 2次元行列と画像が１：１に対応していることが分かります。
        
%% ここでは、10以下のものを除去し、10より大きなものは残したいと思います。
        % C等の言語でやろうとすると、縦方向と横方向の2重のループを使い、
        % 1ピクセルずつ順番に比較したりすると思いますが、
        % MATLABでは行列のまま取り扱えますので、簡潔な記述で処理をすることができます。
       
        % MATLABでは、行列に対する様々な便利な演算子が用意されており、
        % 例えば、行列の各要素と、数値10を比較したいときには、
B=A<10
        % このように、行列と数字10を比べてやることで、
        % 10よりも小さい要素位置には１、10以上のところは0になった行列を得ることができます。
        
%% MATLABでは小かっこを使い要素の指定をするので、
        % 例えば、このようにすることで
A(1,1)
        % 行列のAの第1行・1列目を指定することができます。
        
%% 要素を指定する部分に、数値ではなく行列を使うこともできます。
A(B)    % このように、要素指定部分に、B行列をつかうと
        % B行列の1のところの要素のみ取り出すことができます。
        
%% また、次のようにすることで、B行列の1の要素に対してのみ処理を実行することができます。
A(B)=1

%% これを可視化して確認してみます。
%im     % imと入力して上矢印を押していただくと、コマンド履歴からimshowを入力してくれますが
        % ここでは、画像解析の機能が豊富な、imtoolという別のツールを使ってみます。
imtool(A, []);
        % このように灰色部分が値1になり真っ黒になっていることが分かります。
        % 右下に、マウスの座標やその位置の値が表示されます。
        % 定規アイコンで距離を測ることもできますし、
        % イメージ の下の ピクセル領域 というメニューを使うと、
        % このように各Pixelの明るさの値を表示することもできます。
        % カラーの場合は、3つの値が表示されます


%% 行列をスカラーと同様に扱えます
A+10
sin(A)

%% 飽和処理も自動で行ってくれます
a = uint8(255)
a + 1






        
%% [参考]
%% 先ほど、A行列と10を比べて作ったB行列ですが、
B                

%% これを画像として表示してみると、
imshow(B,[]);
                 % 10よりも小さい要素は白、10より大きい要素は黒の二値画像になっていて、
                 % 大小比較演算だけで2値画像が作れることが分かります。

                 
%%
                 % その他にも、例えば、
B                % このようなB行列の1のところを、先ほどのように1にするのではなく0にしたい場合
~B               % チルダで、行列の0と1を一括で変換できるので、
A                % A行列と
A .* ~B          % チルダB の各行列の要素同士の掛け算 (*の前に.を置くことで出来ます)
                 % を行うことで、先ほどの1の代わりに0へ変換することもできます。

%% Copyright 2014 The MathWorks, Inc.
