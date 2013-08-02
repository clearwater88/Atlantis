function [res,dirtyCoords] = getProbMapCells(ruleId,slot,chType,refPoint,probMapStruct,imSize,angles,cellParams)
    % prob map in cells, [imSize x num angles]. Num angles steps in
    % angleDisc.
    % returns prob maps according to order in poseCellLocs
    
    centres = cellParams.centres{chType};
    centreBoundaries = cellParams.centreBoundaries{chType};
    coords = cellParams.coords{chType};
    
    resPixels = getProbMapPixels(ruleId,slot,refPoint,probMapStruct,imSize,angles);

    offset = probMapStruct.offset{ruleId}(slot,:);
    covar = probMapStruct.cov{ruleId}(:,:,slot);
    centreUse = refPoint+offset;

    [~,D] = eig(covar(1:2,1:2));
    maxStd = sqrt(max(D(:))); % find std of spatial direction of max variance
    
    dirtyBounds(1:2,1) = centreUse(1:2)-3*maxStd;
    dirtyBounds(1:2,2) = centreUse(1:2)+3*maxStd;
    
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
        sumXY = sum(sum(mapXY,1),2);
        sumXY = sumXY(:);
        
        indStart = find(abs(angles - centre(3)) < 0.001,1,'first');
        nAngleBins = floor(abs(bd(3,2)-bd(3,1))/abs(angles(2)-angles(1)))/2;
        
        temp = sumXY(indStart);
        for (j=1:nAngleBins)
            indUseLow = mod(indStart-1-j,numel(sumXY))+1;
            indUseHigh = mod(indStart-1+j,numel(sumXY))+1;
            temp=temp+sumXY(indUseLow)+sumXY(indUseHigh);

        end
        
%         temp = 0;
%         for (j=1:nAngleBins)
%            indUse = mod(indStart-j,numel(sumXY))+1;
%            temp=temp+sumXY(indUse);
%         end
        res(i) = temp;
    end
    res = res/sum(res);
end

