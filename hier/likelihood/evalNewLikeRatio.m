function [ratios] = evalNewLikeRatio(initLike,initCounts,likePxStruct,dirtyRegion,oldRatios)

    nTypes = size(likePxStruct.likes,1);

    ratios = cell(nTypes,1);    
    for (n=1:nTypes)
        likesUse = likePxStruct.likes{n};
        countsUse = likePxStruct.counts{n};
        boundariesUse = likePxStruct.boundaries{n};
        
        if(~isempty(dirtyRegion))
            regionIntersect = doesIntersect(dirtyRegion,boundariesUse);
            oldRatiosUse = oldRatios{n};
        else
            regionIntersect = ones(size(boundariesUse,3),1);
        end
        
        ratioTemp = cell(numel(likesUse),1);
        for (i=1:numel(likesUse))
            
%             if(regionIntersect(i) == 0)
%                ratioTemp(i) = oldRatiosUse(i); 
%                continue;
%             end
            
            bd = boundariesUse(:,:,i);
            initLikeUse = initLike(bd(1,1):bd(1,2),bd(2,1):bd(2,2));
            initCountsUse = initCounts(bd(1,1):bd(1,2),bd(2,1):bd(2,2));
            
            likeTemp = likesUse{i} + initLikeUse;
            countsTemp = countsUse{i} + initCountsUse;
            
            ratioTemp{i} = (likeTemp./countsTemp) ./ (initLikeUse./initCountsUse);            
        end
        ratios{n} = ratioTemp;
    end
    
end

