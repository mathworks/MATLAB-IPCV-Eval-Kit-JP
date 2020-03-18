f1=figure(1); clf reset
set(f1,'units','normalized','position',[0.3652 0.3008 0.6016 0.6016])

[x y z v] = flow;
h=contourslice(x,y,z,v,[1:9],[],[0], linspace(-8,2,10));
axis([0 10 -3 3 -3 3]); daspect([1 1 1])
camva(32); camproj perspective;
campos([-3 -15 5])
set(gcf, 'Color', [.3 .3 .3], 'renderer', 'zbuffer')
set(gca, 'Color', 'black' , 'XColor', 'white', ...
         'YColor', 'white' , 'ZColor', 'white')
box on