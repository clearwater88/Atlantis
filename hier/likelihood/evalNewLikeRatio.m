function [ratios] = evalNewLikeRatio(initLike,initCounts,likePxStruct,dirtyRegion,oldRatios)

    imSize = size(initLike);
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
        
%         anglesDirty = likePxStruct.poses{n}(dirty,3);
%         anglesUse = unique(anglesDirty);
%         for (j=1:numel(anglesUse))
%             tic
%            ind = find(anglesDirty==anglesUse(j));
%            
%            bd = boundariesUse(1:2,:,ind);
%            
%            initLikeUseTemp = zeros(bd(1,2)-bd(1,1)+1,bd(2,2)-bd(2,1)+1,numel(ind));
%            initCountsUseTempp = zeros(bd(1,2)-bd(1,1)+1,bd(2,2)-bd(2,1)+1,numel(ind));
%            for (i=1:numel(ind))
%                initLikeUseTemp(:,:,i) = initLike(bd(1,1,i):bd(1,2,i),bd(2,1,i):bd(2,2,i));
%                initCountsUseTemp(:,:,i) = initCounts(bd(1,1,i):bd(1,2,i),bd(2,1,i):bd(2,2,i));
%            end
%            likesTempFromCell = cell2mat(reshape(likesUse(ind),[1,1,numel(ind)]));
%            countsTempFromCell = cell2mat(reshape(countsUse(ind),[1,1,numel(ind)]));
%             
%            likesTemp = likesTempFromCell + initLikeUseTemp;
%            countsTemp = countsTempFromCell + initCountsUseTemp;
%            
%            toc
%         end
        
        for (j=1:numel(dirty))
            i= dirty(j);
            
            bd = boundariesUse(:,:,i);
            initLikeUse = initLike(bd(1,1):bd(1,2),bd(2,1):bd(2,2));
            initCountsUse = initCounts(bd(1,1):bd(1,2),bd(2,1):bd(2,2));
            
            likesTemp = likesUse{i} + initLikeUse;
            countsTemp = countsUse{i} + initCountsUse;
            
            temp = log((likesTemp./countsTemp) ./ (initLikeUse./initCountsUse));
            ratioTemp{i} =  sum(temp(:));
            %ratioTemp{i} = (likesTemp./countsTemp) ./ (initLikeUse./initCountsUse);
            
        end
        ratios{n} = ratioTemp;
    end
    
end

