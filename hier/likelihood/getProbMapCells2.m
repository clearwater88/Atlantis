function [res,dirtyInds] = getProbMapCells2(ruleId,slot,refPoint,probMapStruct,imSize,angleDisc,centreBoundaries)
    % prob map in cells, [imSize x num angles]. Num angles steps in
    % angleDisc.
    % returns prob maps according to order in poseCellLocs
    
    resPixels = getProbMapPixels(ruleId,slot,refPoint,probMapStruct,imSize,angleDisc);

    offset = probMapStruct.offset{ruleId}(slot,:);
    covar = probMapStruct.cov{ruleId}(:,:,slot);
    centreUse = refPoint+offset;

    [~,D] = eig(covar(1:2,1:2));
    maxStd = sqrt(max(D(:))); % find std of spatial direction of max variance
    
    dirtyBounds(1:2,1) = max(1,centreUse(1:2)-3*maxStd);
    dirtyBounds(1:2,2) = centreUse(1:2)+4*maxStd;
    dirtyBounds(2,1) = min(imSize(1), dirtyBounds(2,1));
    dirtyBounds(2,2) = min(imSize(2), dirtyBounds(2,2));
    
    dirtyInds = find(doesIntersect(dirtyBounds,centreBoundaries(1:2,:,:))==1);
    
    res= zeros(numel(dirtyInds),1);
    for (i=1:numel(dirtyInds))
        bd = centreBoundaries(:,:,dirtyInds(i));
        
        mapXY = resPixels(bd(1,1):bd(1,2), ...
                          bd(2,1):bd(2,2), ...
                          :);
        sumXY = sum(sum(mapXY,1),2);
        sumXY = sumXY(:);

        indStart = find(angleDisc(1):angleDisc(2):angleDisc(3) >= bd(3,1),1,'first');
        nAngleBins = (bd(3,2)-bd(3,1))/angleDisc(2);
        
        temp = 0;
        for (j=0:nAngleBins-1)
           indUse = mod(indStart-1+j,numel(sumXY))+1;
           temp=temp+sumXY(indUse);
        end
        res(i) = temp;
    end
    res = res/sum(res);

end

