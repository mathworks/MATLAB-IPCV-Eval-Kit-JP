f1=figure(1); clf reset
set(f1,'units','normalized','position',[0.3652 0.3008 0.6016 0.6016])

[x y z v] = flow;
p = patch(isosurface(x, y, z, v, 0));
isonormals(x,y,z,v,p);
set(p, 'facecolor', 'r', 'edgecolor', 'n');
daspect([1 1 1]);
view(3);
camlight 
lighting p
%isolims(x,y,z,v)
camproj p; 
    
delete(p)

for i = -11:2
  p = patch(isosurface(x, y, z, v, i, 'v'));
  isonormals(x,y,z,v,p);
  set(p, 'facec', 'f', 'cdata', i, 'edgec', 'n');
end

set(gcf, 'color', [.3 .3 .3])
set(gca, 'color', 'k')
set(gca, 'xcolor', 'w')
set(gca, 'ycolor', 'w')
set(gca, 'zcolor', 'w')
box on
% lighting g
lighting phong
colorbar;

axis tight

p = findobj('type', 'patch');
caxis(caxis)

