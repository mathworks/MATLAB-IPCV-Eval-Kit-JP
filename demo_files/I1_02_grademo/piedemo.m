f1=figure(1); clf reset
set(f1,'units','normalized','position',[0.3652 0.3008 0.6016 0.6016])

x=[1 3 0.5 2.5 2];
explode=[0 0 0 1 0];
subplot(1,2,1),pie(x,explode)
subplot(1,2,2),pie3(x,explode);
colormap(cool)
