f1=figure(1); clf reset
set(f1,'units','normalized','position',[0.3652 0.3008 0.6016 0.6016])

t=0:pi/50:10*pi;
plot3(sin(t),cos(t),t);
grid
xlabel('x')
ylabel('y')
zlabel('z')
