function I4_10_2_plot3DBBox(pc,color,axx)
    % Copyright 2018 The MathWorks, Inc.
    xyzmax = [pc.XLimits(1) pc.YLimits(1) pc.ZLimits(1)];
    xyzmin = [pc.XLimits(2) pc.YLimits(2) pc.ZLimits(2)];
    cubePoints1 = [xyzmin; 
             xyzmax(1)  xyzmin(2:3);
             xyzmax(1:2) xyzmin(3);
             xyzmin(1) xyzmax(2) xyzmin(3)];
    cubePoints2 = cubePoints1;
    cubePoints2(:,3)=xyzmax(3); 
    cubePoints = reshape([cubePoints1 cubePoints2]',[3 8])';
    cubePoints = [cubePoints; reshape([cubePoints1 circshift(cubePoints1,-1,1)]',[3 8])'];
    cubePoints = [cubePoints; reshape([cubePoints2 circshift(cubePoints2,-1,1)]',[3 8])'];
    cubeLines = reshape(cubePoints',6,[])';
    for k = 1:12
        plot3(cubeLines(k,[1 4]),cubeLines(k,[2 5]),cubeLines(k,[3 6]),...
            'Color',color,'LineWidth',3,'Parent',axx);
    end
end