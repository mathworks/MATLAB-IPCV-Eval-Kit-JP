f1=figure(1); clf reset
set(f1,'units','normalized','position',[0.3652 0.3008 0.6016 0.6016])

[X,Y,Z]=peaks;
contour3(X,Y,Z,20)
colorbar
