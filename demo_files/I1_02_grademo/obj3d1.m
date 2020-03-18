f1=figure(1); clf reset
set(f1,'units','normalized','position',[0.3652 0.3008 0.6016 0.6016])

[x1,y1,z1]=sphere(30);
[x2,y2,z2]=cylinder(1:-0.05:0,20);
x2=x2-1;
y2=y2-1;
z2=z2-1;
surf(x1,y1,z1)
hold on
surf(x2,y2,z2)
light('position',[1 -1 1]);
shading interp
lighting phong
colormap(copper)
axis equal
title('3次元オブジェクト','fontname','ＭＳ ゴシック')
