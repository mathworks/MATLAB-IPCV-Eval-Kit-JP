f1=figure(1); clf reset
set(f1,'units','normalized','position',[0.3652 0.3008 0.6016 0.6016])

[X,Y,Z]=peaks;
[c,h]=contourf(X,Y,Z,[-7 -5.5 -1 0 0.9 2.6 4.7 8]);
clabel(c,h)
colorbar
