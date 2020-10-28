f1=figure(1); clf reset
set(f1,'units','normalized','position',[0.3652 0.3008 0.6016 0.6016])

x=randn(500,1);
histogram(x,20)
title('ヒストグラム','fontname','ＭＳ ゴシック')

histfit(x,20)
title('ヒストグラム','fontname','ＭＳ ゴシック')
