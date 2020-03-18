f1=figure(1); clf reset
set(f1,'units','normalized','position',[0.3652 0.3008 0.6016 0.6016])

load clown
[x,y,z]=cylinder;


subplot(2,2,1)
image(X)
axis image

subplot(2,2,3)
h=mesh(x,y,z);
set(h,'edgecolor',[0 0 0])


subplot(122)
warp(x,y,z,flipud(X),map)
axis square