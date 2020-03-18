f1=figure(1); clf reset
set(f1,'units','normalized','position',[0.3652 0.3008 0.6016 0.6016])

alpha=0.02; beta=0.5;
t=0:2:200;
y=exp(-alpha*t).*sin(beta*t);
stem(t,y)
title('y=exp^{(-\alphat)}\cdotsin(\betat)')
