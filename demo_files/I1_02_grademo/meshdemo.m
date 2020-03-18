f1=figure(1); clf reset
set(f1,'units','normalized','position',[0.3652 0.3008 0.6016 0.6016])

[x,y,z]=peaks(50);
mesh(x,y,z)
title('メッシュプロット','fontname','ＭＳ ゴシック')
