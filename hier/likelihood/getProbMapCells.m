function [res,dirtyCoords,resPixels] = getProbMapCells(ruleId,slot,chType,refPoint,probMapStruct,imSize,angles,cellParams)
    % prob map in cells, [imSize x num angles]. Num angles steps in
    % angleDisc.
    % returns prob maps according to order in poseCellLocs
    
    centres = cellParams.centres{chType};
    centreBoundaries = cellParams.centreBoundaries{chType};
    coords = cellParams.coords{chType};

    offset = probMapStruct.offset{ruleId}(slot,:);
    covar = probMapStruct.cov{ruleId}(:,:,slot);
    vonM = probMapStruct.vonM(ruleId);
    
    % need to rotate offset
    centreUse(3) = refPoint(3)+offset(3);
    rotMat = [cos(centreUse(3)), sin(centreUse(3)); -sin(centreUse(3)), cos(centreUse(3))];
    centreUse(1:2) = (rotMat*offset(1:2)')' + refPoint(1:2);
    
    resPixels = getProbMapPixels(offset,covar,vonM,refPoint,probMapStruct,imSize,angles);
    
    [~,D] = eig(covar(1:2,1:2));
    maxStd = sqrt(max(D(:))); % find std of spatial direction of max variance
    
    dirtyBounds(1:2,1) = centreUse(1:2)-3*maxStd;
    dirtyBounds(1:2,2) = centreUse(1:2)+3*maxStd;
    dirtyBounds(:,1) = floor(dirtyBounds(:,1));
    dirtyBounds(:,2) = ceil(dirtyBounds(:,2));
    
    dirtyInds = find(doesIntersect(dirtyBounds,centreBoundaries(1:2,:,:))==1);    
    dirtyCoords = coords(dirtyInds,:);
    dirtyBd = centreBoundaries(:,:,dirtyInds);
    dirtyCentre = centres(dirtyInds,:);
    
    res= zeros(numel(dirtyInds),1);
    for (i=1:numel(dirtyInds))
        bd = dirtyBd(:,:,i);
        centre = dirtyCentre(i,:);
        
        mapXY = resPixels(bd(1,1):bd(1,2), ...
                          bd(2,1):bd(2,2), ...
                          :);
        sumXY = squeeze(sum(sum(mapXY,1),2));
        
        indStart = find(abs(angles - centre(3)) < 0.001,1,'first');
        nAngleBins = floor(abs(bd(3,2)-bd(3,1))/abs(angles(2)-angles(1)))/2;
        
        temp = sumXY(indStart);
        for (j=1:nAngleBins)
            indUseLow = mod(indStart-1-j,numel(sumXY))+1;
            indUseHigh = mod(indStart-1+j,numel(sumXY))+1;
            temp=temp+sumXY(indUseLow)+sumXY(indUseHigh);

        end
        res(i) = temp;
    end
    res = res/sum(res);
    
    % prune off further
    tooLow = find(res<0.001);
    res(tooLow) = [];
    dirtyCoords(tooLow,:)=[];
    res=res/sum(res);
    
    assert(~any(isnan(res(:))));
    assert(numel(dirtyCoords) > 0);
end

