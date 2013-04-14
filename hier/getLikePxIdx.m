function res = getLikePxIdx(cellCentre,cellDims,boundaryPx,params)

    cellBoundaries = [cellCentre(1:2)-(cellDims(1:2)-1)/2;  cellCentre(1:2)+(cellDims(1:2)-1)/2]';

    spatialLow = squeeze(sum(bsxfun(@ge,boundaryPx(1:2,1,:),cellBoundaries(:,1)),1));
    spatialLow = spatialLow ==2; % 2 dimensions; have to pass checks for all 3
    
    spatialHigh = squeeze(sum(bsxfun(@le,boundaryPx(1:2,2,:),cellBoundaries(:,2)),1));
    spatialHigh = spatialHigh ==2; % 2 dimensions; have to pass checks for all 3
    
    resSpatial = bsxfun(@and,spatialLow,spatialHigh);
    
    angleLow = cellCentre(3)-cellDims(3);
    angleHigh = cellCentre(3)+cellDims(3);
    
    ags = squeeze(boundaryPx(3,1,:)); 
    resAngle = checkAngle(ags,angleLow,angleHigh);
    
    res = bsxfun(@and,resSpatial,resAngle);
    
end

