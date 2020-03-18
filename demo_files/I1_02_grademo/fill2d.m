f1=figure(1); clf reset
set(f1,'units','normalized','position',[0.3652 0.3008 0.6016 0.6016])

x=-5:0.05:5;
p=[1 0 -20 10];
y=polyval(p,x);
r=sort(roots(p));
x1=r(1):0.1:r(2);
y1=polyval(p,x1);
plot(x,y)
hold on
fill(x1,y1,'r')
grid
