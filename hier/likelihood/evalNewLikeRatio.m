function [ratios] = evalNewLikeRatio(data,templateStruct,initLike,initCounts,posesStruct,dirtyRegion,oldRatios,params)

    nTypes = numel(posesStruct.mask);
    ratios = cell(nTypes,1);
    
    for (n=1:nTypes)
        %likesUse = likePxStruct.likes{n};
        %countsUse = likePxStruct.counts{n};
        boundariesUse = posesStruct.bounds{n};
        
        if(~isempty(dirtyRegion))
            regionIntersect = doesIntersect(dirtyRegion,boundariesUse);
            oldRatiosUse = oldRatios{n};
        else
            regionIntersect = ones(size(boundariesUse,3),1);
        end
        dirty = find(regionIntersect==1);

        
        if(~isempty(dirtyRegion)) % if have dirtyRegion, then have oldRatios
            ratioTemp = oldRatiosUse;
        else
            ratioTemp = ones(size(boundariesUse,3),1);
        end
        
        [dirtyPartitions,ags] = splitDirty(n,dirty,params.evalLikeDims,posesStruct);
        
        for (i=1:size(dirtyPartitions,2))
           agInd = find(abs(posesStruct.angles-ags(i)) < 0.001);
           likes = evalLikePartition(dirty,dirtyPartitions(:,i),agInd,n,posesStruct,data,params);
        end
        
%         for (j=1:numel(dirty))
%             i= dirty(j);
%             
%             bd = boundariesUse(:,:,i);
%             initLikeUse = initLike(bd(1,1):bd(1,2),bd(2,1):bd(2,2));
%             initCountsUse = initCounts(bd(1,1):bd(1,2),bd(2,1):bd(2,2));
%             
%             likesTemp = likesUse{i} + initLikeUse;
%             countsTemp = countsUse{i} + initCountsUse;
% 
%             temp = log((likesTemp./countsTemp) ./ (initLikeUse./initCountsUse));
%             ratioTemp(i) =  sum(temp(:));
%             
%         end
        
        ratios{n} = ratioTemp;
    end
    
end

function likes = evalLikePartition(dirty,partition,agInd,type,posesStruct,data,params)
    template = posesStruct.rotTemplate{type}{agInd};
    mask = posesStruct.mask{type}{agInd};
    counts = posesStruct.counts{type}{agInd};
end

function [dirtyPartitions,ags] = splitDirty(type,dirty,evalLikeDims,posesStruct)
    % partitions dirty region (pixel-space) for low-memory-footprint
    % evaluation of likelihoods. Each partition is guaranteed to have all
    % the same angle

    dirtyPartitions = [];
    ags = [];
    
    boundsDirty = posesStruct.bounds{type}(:,:,dirty);
    posesDirty = posesStruct.poses{type}(dirty,:);
    posesDirtyStart = min(posesDirty(:,1:2),[],1);
    posesDirtyEnd = max(posesDirty(:,1:2),[],1);
    
    boundsAngle =squeeze(boundsDirty(3,1,:));
    
    xStart = [posesDirtyStart(1):evalLikeDims(1):posesDirtyEnd(1)];
    yStart = [posesDirtyStart(2):evalLikeDims(2):posesDirtyEnd(2)];
    
    [y,x] = meshgrid(yStart,xStart);
    startLocs = [x(:),y(:)];
    
    % assume square region
    
    for (i=1:numel(posesStruct.angles))
        ag = posesStruct.angles(i);
        inds = abs(boundsAngle-ag) < 0.001;
        boundsUse = boundsDirty(:,:,inds);
        for (j=1:size(startLocs,1))
            endLoc = startLocs(j,:) + evalLikeDims - [1,1];
            inPartition = doesIntersect([startLocs(j,:)',endLoc'],boundsUse);
            temp = zeros(size(inds,1),1);
            temp(inds) = inPartition;
            dirtyPartitions = cat(2,dirtyPartitions,temp);
            ags = cat(2,ags,ag);
        end
    end
end




































