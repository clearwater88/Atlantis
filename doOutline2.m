function res = doOutline2(samp,partSize,imSize,qParts)

    res = zeros(imSize);
    
    % Just take most likely assignment
    qPartUse = qParts{1}(:) > 0.5; 
    
    
    for (i=1:numel(samp)/3)
        tempIm = zeros(imSize);
        y = samp(3*(i-1)+1); x = samp(3*(i-1)+2); rot = samp(3*(i-1)+3); fs = 0;
        fillSource = 0;

        yStart = y-partSize(1); yEnd = y+partSize(1);
        xStart = x-partSize(2); xEnd = x+partSize(2);

        pts = meshgridRaster(yStart:yEnd,xStart:xEnd);
        [rotPts,~,corresPtsInd] = rotatePts(pts,[y,x],rot,fs,fillSource,imSize);

        rotPtsInd = (rotPts(:,2)-1)*imSize(1)+rotPts(:,1);


        tempIm(rotPtsInd) = qPartUse(corresPtsInd);
        %tempIm = bwmorph(tempIm,'remove');

        res = res+tempIm;
        
    end
end

