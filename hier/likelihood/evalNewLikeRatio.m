function [ratios] = evalNewLikeRatio(initLike,initCounts,likePxStruct,dirtyRegion,oldRatios)

    nTypes = size(likePxStruct.likes,1);

    ratios = cell(nTypes,1);    
    for (n=1:nTypes)
        likesUse = likePxStruct.likes{n};
        countsUse = likePxStruct.counts{n};
        boundariesUse = likePxStruct.bounds{n};
        
        if(~isempty(dirtyRegion))
            regionIntersect = doesIntersect(dirtyRegion,boundariesUse);
            oldRatiosUse = oldRatios{n};
        else
            regionIntersect = ones(size(boundariesUse,3),1);
        end
        dirty = find(regionIntersect==1);
        
        ratioTemp = cell(numel(likesUse),1);
        if(~isempty(dirtyRegion)) % if have dirtyRegion, then have oldRatios
            ratioTemp(regionIntersect==0) = oldRatiosUse(regionIntersect==0);
        end
        
        for (j=1:numel(dirty))
            i= dirty(j);
            
            bd = boundariesUse(:,:,i);
            initLikeUse = initLike(bd(1,1):bd(1,2),bd(2,1):bd(2,2));
            initCountsUse = initCounts(bd(1,1):bd(1,2),bd(2,1):bd(2,2));
            
            likesTemp = likesUse{i} + initLikeUse;
            countsTemp = countsUse{i} + initCountsUse;
            
            ratioTemp{i} = (likesTemp./countsTemp) ./ (initLikeUse./initCountsUse);
            
        end
        ratios{n} = ratioTemp;
    end
    
end

