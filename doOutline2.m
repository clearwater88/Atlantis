function res = doOutline2(samp,partSizes,imSize,qParts)

    res = zeros(imSize);
    
    
    for (i=1:numel(samp)/4)
        tempIm = zeros(imSize);
        y = samp(4*(i-1)+1);
        x = samp(4*(i-1)+2);
        rot = samp(4*(i-1)+3); 
        partNum = samp(4*(i-1)+4);
        
        fs = 0;
        fillSource = 0;

        yStart = y-partSizes(partNum,1); yEnd = y+partSizes(partNum,1);
        xStart = x-partSizes(partNum,2); xEnd = x+partSizes(partNum,2);

        pts = meshgridRaster(yStart:yEnd,xStart:xEnd);
        [rotPts,~,corresPtsInd] = rotatePts(pts,[y,x],rot,fs,fillSource,imSize);

        rotPtsInd = (rotPts(:,2)-1)*imSize(1)+rotPts(:,1);

        % Just take most likely assignment
        qPartUse = qParts{partNum}(:)  > 0.5; 
        tempIm(rotPtsInd) = qPartUse(corresPtsInd);
        %tempIm = bwmorph(tempIm,'remove');

        res = res+tempIm;
        
    end
end

