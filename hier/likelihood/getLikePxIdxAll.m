function res = getLikePxIdxAll(cellCentre,cellDims,boundaryPx)

    %cellBoundaries = [bsxfun(cellCentre(:,1:2)-(cellDims(1:2)-1)/2);  cellCentre(:,1:2)+(cellDims(1:2)-1)/2]';

    lowCell = bsxfun(@minus,cellCentre(:,1:2),(cellDims(1:2)-1)/2)';
    highCell = bsxfun(@plus,cellCentre(:,1:2),(cellDims(1:2)-1)/2)'; 
    
    % size: #cellCentres x # pixels (size(boundaryPx,3))
    spatialLow = squeeze(sum(bsxfun(@ge,boundaryPx(1:2,1,:),lowCell),1));
    spatialLow = spatialLow == 2; % any of the 2 spatial dimensions outside of range?
    
    % size: #cellCentres x # pixels (size(boundaryPx,3))
    spatialHigh = squeeze(sum(bsxfun(@le,boundaryPx(1:2,2,:),highCell),1));
    spatialHigh = spatialHigh == 2; % any of the 2 spatial dimensions outside of range?
    
    resSpatial = bsxfun(@and,spatialLow,spatialHigh);
    
%     angleLow = cellCentre(:,3)-cellDims(3)/2;
%     angleHigh = cellCentre(:,3)+cellDims(3)/2;
%     
%     ags = squeeze(boundaryPx(3,1,:)); % only 1 angle anyway
%     resAngle = checkAngle(ags',angleLow,angleHigh);
%     
%     res = bsxfun(@and,resSpatial,resAngle);
%     res=res';

    res = resSpatial';
end


