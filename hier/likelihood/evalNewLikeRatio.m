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
    bd = posesStruct.bounds{type}(:,:,partition);
    
    b2 = reshape(bd(1:2,1:2,:),[4,numel(bd(1:2,1:2,:))/4]);            
    rg = reshape([1:size(b2,2)],[1,1,size(b2,2)]);
    
    dataUse = arrayfun(@(x)(data(b2(1,x):b2(3,x),b2(2,x):b2(4,x))),rg,'UniformOutput',0);
    dataUse = cell2mat(dataUse);
end

function [dirtyPartitions,ags] = splitDirty(type,dirty,evalLikeDims,posesStruct)
    % partitions dirty region (pixel-space) for low-memory-footprint
    % evaluation of likelihoods. Each partition is guaranteed to have all
    % the same angle

    dirtyPartitions = logical([]);
    ags = [];
    
    posesDirty = posesStruct.poses{type}(dirty,:);
    posesDirtyStart = min(posesDirty(:,1:2),[],1);
    posesDirtyEnd = max(posesDirty(:,1:2),[],1);
    
    posesAngle = posesDirty(:,3);
    
    xStart = [posesDirtyStart(1):evalLikeDims(1):posesDirtyEnd(1)];
    yStart = [posesDirtyStart(2):evalLikeDims(2):posesDirtyEnd(2)];
    
    [y,x] = meshgrid(yStart,xStart);
    startLocs = [x(:),y(:)];
    
    % assume square region
    
    for (i=1:numel(posesStruct.angles))
        ag = posesStruct.angles(i);
        inds = abs(posesAngle-ag) < 0.001;
        posesUse = posesDirty(inds,:);
        for (j=1:size(startLocs,1))
            endLoc = startLocs(j,:) + evalLikeDims - [1,1];
            
            inPartition = bsxfun(@le,startLocs(j,:),posesUse(:,1:2)) .* ...
                          bsxfun(@ge,endLoc,posesUse(:,1:2));
            inPartition = (sum(inPartition,2) == 2);
            
            temp = logical(zeros(size(inds,1),1));
            temp(inds) = inPartition;
            dirtyPartitions = cat(2,dirtyPartitions,temp);
            ags = cat(2,ags,ag);
        end
    end
end




































