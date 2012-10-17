function [rotPtsInd,corresPts,origPtsInd] = doGetLikeInds(y,x,rot,fs,partSize,imSize,fillSource)

    yStart = y-partSize(1); yEnd = y+partSize(1);
    xStart = x-partSize(2); xEnd = x+partSize(2);

    pts = meshgridRaster(yStart:yEnd,xStart:xEnd);
    [rotPts,corresPts,origPtsInd] = rotatePts(pts,[y,x],rot,fs,fillSource);
    rotPtsInd = (rotPts(:,2)-1)*imSize(1)+rotPts(:,1);
end

