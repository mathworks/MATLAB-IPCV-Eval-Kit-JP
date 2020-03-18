f1=figure(1); clf('reset')
set(f1,'units','normalized','position',[0.3652 0.3008 0.6016 0.6016])

load headsmall
[x y z data2] = subvolume(data, [nan 30    nan 30   nan 45]);
p = patch(isosurface(x,y,z,data2, 30), 'FaceColor', 'r', 'EdgeColor', 'n');
isonormals(x,y,z,data2,p)
p2 = patch(isocaps(x,y,z,data2, 30), 'FaceColor', 'i', 'EdgeColor', 'n');

[x y z data2] = subvolume(data, [30 nan    nan nan   nan nan]);
p = patch(isosurface(x,y,z,data2, 30), 'FaceColor', 'r', 'EdgeColor', 'n');
isonormals(x,y,z,data2, p)
p2 = patch(isocaps(x,y,z,data2, 30), 'FaceColor', 'i', 'EdgeColor', 'n');

view(-130,30);axis vis3d tight; daspect([1 1 1]); h = camlight('left'); 
lighting phong
colormap(gray(100))

set(gcf, 'color', [.3 .3 .3])
set(gca, 'color', 'k')
set(gca, 'xcolor', 'w')
set(gca, 'ycolor', 'w')
set(gca, 'zcolor', 'w')
