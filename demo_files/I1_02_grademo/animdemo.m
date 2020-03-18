f1=figure(1); clf reset
set(f1,'units','normalized','position',[0.3652 0.3008 0.6016 0.6016])

load('animdemo_anim')

sz = get(0,'ScreenSize');
% アニメーションを3回繰り返す
movie(f1, F, 3, 30,[(0.6016*sz(3)-560)/2 (0.6016*sz(4)-420)/2 0 0])




%% animdemo_anim.m  の作製法
% figure('Renderer','zbuffer')
% Z = peaks;
% surf(Z); 
% axis tight
% set(gca,'NextPlot','replaceChildren');
% % Preallocate the struct array for the struct returned by getframe
% F(20) = struct('cdata',[],'colormap',[]);
% % Record the movie
% for j = 1:20 
%     surf(.01+sin(2*pi*j/20)*Z,Z)
%     F(j) = getframe;
% end
% save('animdemo_anim.mat', 'F');

