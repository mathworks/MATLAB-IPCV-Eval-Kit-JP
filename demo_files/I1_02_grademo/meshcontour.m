f1=figure(1); clf reset
set(f1,'units','normalized','position',[0.0098 0.3529 0.5469 0.5469])
load data3d1
h=surf(x(:,:,30),y(:,:,30),130*ones(21,31)-130,v(:,:,30)*30-125);
%set(h,'edgecolor','none')
shading interp
hold on
h=mesh(x(:,:,30),y(:,:,30),v(:,:,30)*30-125);
set(h,'facecolor','none')
[c,h]=contour3(x(:,:,30),y(:,:,30),v(:,:,30)*30-125,10,'k');
set(h,'linewidth',1)
axis equal
map=jet(64);
colormap(map(10:end,:))

f2=figure(2); clf reset
set(f2,'units','normalized','position',[0.4385 0.0182 0.5469 0.5469])
[px,py]=gradient(v(:,:,30));
contour(x(:,:,30),y(:,:,30),v(:,:,30),20)
hold on
h=quiver(x(:,:,30),y(:,:,30),px,py);
set(h,'color','k','linewidth',1)
axis equal
axis([0 60 0 40])
map=jet(64);
colormap(map(10:end,:))