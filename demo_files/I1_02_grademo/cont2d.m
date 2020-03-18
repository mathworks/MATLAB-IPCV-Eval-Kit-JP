f1=figure(1); clf reset
set(f1,'units','normalized','position',[0.3652 0.3008 0.6016 0.6016])

[X,Y]=meshgrid(-2:.2:2,-2:.2:2);
Z = X.*exp(-X.^2-Y.^2);
[c,h]=contour(X,Y,Z);
clabel(c,h)
title('z=xe^{(-x^2-y^2)}')
