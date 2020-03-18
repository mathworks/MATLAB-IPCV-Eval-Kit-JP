f1=figure(1); clf reset
set(f1,'units','normalized','position',[0.3652 0.3008 0.6016 0.6016])

[x,y,z]=peaks(50);
surf(x,y,z)
title('表面プロット','fontname','ＭＳ ゴシック')
