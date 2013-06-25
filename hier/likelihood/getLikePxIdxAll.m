function res = getLikePxIdxAll(cellCentre,cellDims,poseCentres)
    NBATCH = 200;

    lowCell = bsxfun(@minus,cellCentre(:,1:2),(cellDims(1:2)-1)/2)';
    highCell = bsxfun(@plus,cellCentre(:,1:2),(cellDims(1:2)-1)/2)'; 
    
    poseCentres = reshape(poseCentres',[3,1,numel(poseCentres)/3]);
    % size: #cellCentres x # pixels (size(poseCentres,3))
    
    sz = size(poseCentres,3);
    batchSize = ceil(sz/NBATCH);
    res = zeros(sz,size(lowCell,2));
    for (n=1:NBATCH)
        nStart = (n-1)*batchSize+1;
        nEnd = min(n*batchSize,sz);
        spatialLow = squeeze(sum(bsxfun(@ge,poseCentres(1:2,1,nStart:nEnd),lowCell),1));
        spatialLow = spatialLow == 2; % any of the 2 spatial dimensions outside of range?

        % size: #cellCentres x # pixels (size(poseCentres,3))
        spatialHigh = squeeze(sum(bsxfun(@le,poseCentres(1:2,1,nStart:nEnd),highCell),1));
        spatialHigh = spatialHigh == 2; % any of the 2 spatial dimensions outside of range?

        resSpatial = bsxfun(@and,spatialLow,spatialHigh);

        angleLow = cellCentre(:,3)-cellDims(3)/2;
        angleHigh = cellCentre(:,3)+cellDims(3)/2;

        ags = squeeze(poseCentres(3,1,nStart:nEnd)); % only 1 angle anyway
        resAngle = checkAngle(ags',angleLow,angleHigh);

        res(nStart:nEnd,:) = bsxfun(@and,resSpatial,resAngle)';
    end
end


