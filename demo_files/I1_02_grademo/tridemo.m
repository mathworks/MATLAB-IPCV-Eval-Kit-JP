f1=figure(1); clf reset
set(f1,'units','normalized','position',[0.0098 0.3529 0.5469 0.5469])
load seamount
tr=delaunay(x,y);
trisurf(tr,x,y,z)
axis([210.85 211.7 -48.45 -47.95 -4300 -500])
map=pink(64);
colormap(map(10:end,:))

f2=figure(2); clf reset
set(f2,'units','normalized','position',[0.4385 0.0182 0.5469 0.5469])
plot(x,y,'k.','markersize',10)
hold on
trimesh(tr,x,y,z)
hidden off
grid
map=pink(64);
colormap(map(10:end,:))
