f1=figure(1); clf reset
set(f1,'units','normalized','position',[0.3652 0.3008 0.6016 0.6016])

Y=rand(5);
subplot(2,2,1),bar(Y,'stacked')
subplot(2,2,2),barh(Y(:,1)) 

X=rand(5);
subplot(2,3,4),bar3(X), set(gca,'ylim',[0 6])
subplot(2,3,5),bar3(X,'grouped')
subplot(2,3,6),bar3(X,'stacked')
colormap(summer)
