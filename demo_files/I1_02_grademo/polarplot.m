f1=figure(1); clf reset
set(f1,'units','normalized','position',[0.3652 0.3008 0.6016 0.6016])

theta=0:2*pi/100:2*pi;
r=theta/(2*pi);
polarplot(theta,r)
