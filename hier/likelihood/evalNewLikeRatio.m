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
        
%         ratioTemp = cell(numel(likesUse),1);
%         if(~isempty(dirtyRegion)) % if have dirtyRegion, then have oldRatios
%             ratioTemp(regionIntersect==0) = oldRatiosUse(regionIntersect==0);
%         end
        
        
        if(~isempty(dirtyRegion)) % if have dirtyRegion, then have oldRatios
            ratioTemp = oldRatiosUse;
            %ratioTemp2 = oldRatiosUse;
        else
            ratioTemp = ones(numel(likesUse),1);
            %ratioTemp2 = ones(numel(likesUse),1);
        end
        
        for (j=1:numel(dirty))
            i= dirty(j);
            
            bd = boundariesUse(:,:,i);
            initLikeUse = initLike(bd(1,1):bd(1,2),bd(2,1):bd(2,2));
            initCountsUse = initCounts(bd(1,1):bd(1,2),bd(2,1):bd(2,2));
            
            likesTemp = likesUse{i} + initLikeUse;
            countsTemp = countsUse{i} + initCountsUse;

            temp = log((likesTemp./countsTemp) ./ (initLikeUse./initCountsUse));
            ratioTemp(i) =  sum(temp(:));
            
        end

%         anglesDirty = likePxStruct.poses{n}(dirty,3);
%         anglesUse = unique(anglesDirty);
%         tic
%         for (j=1:numel(anglesUse))
%            ind = find(anglesDirty==anglesUse(j));
%            
%            bd = boundariesUse(1:2,:,ind);
%            
% %            initLikeUseTemp = zeros(bd(1,2)-bd(1,1)+1,bd(2,2)-bd(2,1)+1,numel(ind));
% %            initCountsUseTemp = zeros(bd(1,2)-bd(1,1)+1,bd(2,2)-bd(2,1)+1,numel(ind));
% %            for (i=1:numel(ind))
% %                initLikeUseTemp(:,:,i) = initLike(bd(1,1,i):bd(1,2,i),bd(2,1,i):bd(2,2,i));
% %                initCountsUseTemp(:,:,i) = initCounts(bd(1,1,i):bd(1,2,i),bd(2,1,i):bd(2,2,i));
% %            end
%            likesTempFromCell = cell2mat(reshape(likesUse(ind),[1,1,numel(ind)]));
%            countsTempFromCell = cell2mat(reshape(countsUse(ind),[1,1,numel(ind)]));
%            
%            rg = 1:numel(ind);
%            initLikeUseTemp = arrayfun(@(x)(initLike(bd(1,1,x):bd(1,2,x),bd(2,1,x):bd(2,2,x))),rg,'UniformOutput',0);
%            initLikeUseTemp = cell2mat(reshape(initLikeUseTemp,[1,1,numel(initLikeUseTemp)]));
%            
%            initCountsUseTemp = arrayfun(@(x)(initCounts(bd(1,1,x):bd(1,2,x),bd(2,1,x):bd(2,2,x))),rg,'UniformOutput',0);
%            initCountsUseTemp = cell2mat(reshape(initCountsUseTemp,[1,1,numel(initCountsUseTemp)]));
%            
%            likesTemp = likesTempFromCell + initLikeUseTemp;
%            countsTemp = countsTempFromCell + initCountsUseTemp;
%            
%            temp = log((likesTemp./countsTemp) ./ (initLikeUseTemp./initCountsUseTemp));
%            ratioTemp2(ind) = squeeze(sum(sum(temp,1),2));
%         end
%         toc
%         a=abs(ratioTemp2-ratioTemp);
%         assert(max(a(:))<0.0001);
        
        ratios{n} = ratioTemp;
    end
    
end

