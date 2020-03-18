f1=figure(1); clf reset
set(f1,'units','normalized','position',[0.3652 0.3008 0.6016 0.6016])

[x,y,z] = meshgrid(-2:.1:2, -2:.1:2, -2:.1:2);
v = x .* exp(-x.^2 - y.^2 - z.^2);

[xi,yi]=meshgrid(0:.1:4);
zi=xi.^2+yi.^2;


slice(x,y,z,v,[.8 ],[],[ -.5])
hold on
slice(x,y,z,v,xi-2,yi-2,zi/8-2);
hold off
