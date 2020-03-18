f1=figure(1); clf reset
set(f1,'units','normalized','position',[0.3652 0.3008 0.6016 0.6016])
x=-3:0.1:3;
y1=sin(x);
y2=sin(x.^2);
y3=cos(x.^2);
plot(x,y1,x,y2,'--',x,y3,':')
title('sin(x), sin(x^2), cos(x^2)')
