function res = getLikePxIdx(cellCentre,cellDims,boundaryPx)
    error(blah);
    cellBoundaries = [cellCentre(1:2)-(cellDims(1:2)-1)/2;  cellCentre(1:2)+(cellDims(1:2)-1)/2]';

    spatialLow = squeeze(sum(bsxfun(@ge,boundaryPx(1:2,1,:),cellBoundaries(:,1)),1));
    spatialLow = spatialLow == 2; % any of the 2 spatial dimensions outside of range?
    
    spatialHigh = squeeze(sum(bsxfun(@le,boundaryPx(1:2,2,:),cellBoundaries(:,2)),1));
    spatialHigh = spatialHigh ==2; % any of the 2 spatial dimensions outside of range?
    
    resSpatial = bsxfun(@and,spatialLow,spatialHigh);
    
    angleLow = cellCentre(3)-cellDims(3)/2;
    angleHigh = cellCentre(3)+cellDims(3)/2;
    
    ags = squeeze(boundaryPx(3,1,:)); 
    resAngle = checkAngle(ags,angleLow,angleHigh);
    
    res = bsxfun(@and,resSpatial,resAngle);
    
end

