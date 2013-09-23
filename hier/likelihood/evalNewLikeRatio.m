function [ratios] = evalNewLikeRatio(data,templateStruct,initLikes,initCounts,posesStruct,dirtyRegion,oldRatios,params)

    nTypes = numel(posesStruct.mask);
    ratios = cell(nTypes,1);
    
    for (n=1:nTypes)
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
           ids = dirty(dirtyPartitions(:,i));
           ratioTemp(ids) = evalLikeRatioPartition(dirty(dirtyPartitions(:,i)),agInd,n,initLikes,initCounts,posesStruct,data,templateStruct.mix,params.alpha);
        end
        
        ratios{n} = ratioTemp;
    end
    
end

function res = evalLikeRatioPartition(partition,agInd,type,initLikes,initCounts,posesStruct,data,mix,alpha)
    template = posesStruct.rotTemplate{type}{agInd};
    mask = posesStruct.mask{type}{agInd};
    counts = posesStruct.counts{type}{agInd};
    bd = posesStruct.bounds{type}(:,:,partition);
    
    % all sizes guaranteed to be same
    sz = [bd(1,2,1)-bd(1,1,1)+1,bd(2,2,1)-bd(2,1,1)+1];

    d2 = zeros([sz,size(bd,3)]);
    dataUse = collect(double(data),bd,size(bd,3),size(bd,1)*size(bd,2),size(data),prod(sz),d2);
    likeUse = collect(double(initLikes),bd,size(bd,3),size(bd,1)*size(bd,2),size(initLikes),prod(sz),d2);
    countsUse = collect(double(initCounts),bd,size(bd,3),size(bd,1)*size(bd,2),size(initCounts),prod(sz),d2);
   
    likePatch = evalLikePixels(template,dataUse,mask,mix(type));

    likesTot = likePatch+likeUse;
    
    countsTot = bsxfun(@plus,counts,countsUse);

    temp = log(evalLike(likesTot,countsTot,alpha) ./ evalLike(likeUse,countsUse,alpha));
    temp = sum(sum(temp,1),2);
    
    res = reshape(temp,[numel(temp),1]);
    
end

function [dirtyPartitions,ags] = splitDirty(type,dirty,evalLikeDims,posesStruct)
    % partitions 'dirty' region (pixel-space) for low-memory-footprint
    % evaluation of likelihood ratios. Each partition is guaranteed to have all
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
            if(sum(inPartition)==0) continue; end;
            
            temp = false(size(inds,1),1);
            temp(inds) = inPartition;
            dirtyPartitions = cat(2,dirtyPartitions,temp);
            ags = cat(2,ags,ag);
        end
    end
    
end




































