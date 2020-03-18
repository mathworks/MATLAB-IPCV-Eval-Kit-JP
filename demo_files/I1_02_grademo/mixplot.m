f1=figure(1); clf reset
set(f1,'units','normalized','position',[0.3652 0.3008 0.6016 0.6016])

load wind
vel = sqrt(u.*u + v.*v + w.*w);

disp('iso...')
p = patch(isosurface(x, y, z, vel, 40));
isonormals (x, y, z, vel,p)
set(p, 'facecolor', 'r', 'edgecolor', 'n');
p2 = patch(isocaps(x,y,z,vel,40), 'facec', 'i', 'edgec',  'n');
caxis([40 65])


daspect([1 1 1])

[ff vv] = isosurface(x, y, z, vel, 30);
[f verts] = reducepatch(ff,vv, .2);

disp('cones...')
h=coneplot(x,y,z,u,v,w,verts(:,1),verts(:,2),verts(:,3),2);
set(h, 'facec',  [0 .7 .7], 'edgec', 'n')


disp('streams...')
[sx sy sz] = meshgrid(71, 18:8:59, 0:5:15);
verts = stream3(x,y,z,u,v,w,sx,sy,sz);
  sl=streamline(verts);
  %set(sl, 'color', [.3 .3 .3]);
axis vis3d tight

view(3)
camlight 
lighting p
%set(gcf, 'color', [.3 .3 .3])
%set(gca, 'color', 'k')
%set(gca, 'xcolor', 'w')
%set(gca, 'ycolor', 'w')
%set(gca, 'zcolor', 'w')


box on;
camproj p;
camva(33)
campos([150 -25 60]); camtarget([105 40 0]) 