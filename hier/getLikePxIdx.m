function res = getLikePxIdx(cellCentre,cellDims,boundaryPx)

    cellBoundaries = [cellCentre-(cellDims-1)/2;  cellCentre+(cellDims-1)/2]';

    low = squeeze(sum(bsxfun(@ge,boundaryPx(:,1,:),cellBoundaries(:,1)),1));
    low = low ==3; % 3 dimensions; have to pass checks for all 3
    
    high = squeeze(sum(bsxfun(@le,boundaryPx(:,2,:),cellBoundaries(:,2)),1));
    high = high ==3; % 3 dimensions; have to pass checks for all 3
    
    res = bsxfun(@and,low,high);
end

