function [logProbOptions,noConnectParent,parentSlotProbs] = getProbsOn(type,locIdx,bricks,connChild,connPar,ruleStruct,allProbMapCells,likeIm,countsIm,likePxStruct,cellParams,params)
    % optionId: off,on/self-root,on/with-parent

    childCentre = cellParams.centres{type}(locIdx,:);
    
    childLikes = likePxStruct.likes{type};
    childCounts = likePxStruct.counts{type};
    childBounds = likePxStruct.boundaries{type};
    
    types = getType(bricks);
    nBricks = size(bricks,2);
    
    defaultLogLikeIm = sum(log(likeIm(:)./countsIm(:)));

    ids = find(getLikePxIdx(childCentre,cellParams.dims(type,:),childBounds) == 1);
    logProbs = cellLogProbs(ids,likeIm,countsIm,childLikes,childCounts,childBounds);
    logProbs = logProbs + log(1/numel(logProbs)); %add in prior
    cellLogLike = logsum(logProbs,1);
        
    % off,on/self-root,on/with-parent
    logProbOptions(1,1) = defaultLogLikeIm;
    logProbOptions(2,1) = cellLogLike;
    logProbOptions(3,1) =  cellLogLike;
    
    % top-down messages
    [noConnectParent,parentSlotProbs] = sampleParentProbs(type, locIdx, bricks,connChild,ruleStruct,allProbMapCells);
    parentProbNoConnect = prod(noConnectParent);
    
    fromParentUpdate = [log(1-params.probRoot(type)) + log(parentProbNoConnect); ...
                        log(params.probRoot(type)) + log(parentProbNoConnect); ...
                        log(1 - parentProbNoConnect)];
    logProbOptions = logProbOptions + fromParentUpdate;
    
    % bottom-up messages
    noConnectChild = sampleChildProbs(type,locIdx, bricks,ruleStruct,allProbMapCells);
    selfRooted = find(isSelfRooted(bricks,connPar)==1);
    selfRootingProb = ones(1,nBricks);
    selfRootingProb(selfRooted) = params.probRoot(types(selfRooted));
    
    % on: p(s_child | brick on) = \sum_{connect,noconnect} p(s_child | connected, brick on) p(connected | brick on)
    % off: p(s_child | brick off), imples connected = off
    on = 1*(1-noConnectChild) + selfRootingProb.*noConnectChild;
    off = selfRootingProb;
    
    fromChildUpdate = [sum(log(off)); ...
                       sum(log(on)); ...
                       sum(log(on))];
    logProbOptions = logProbOptions+ fromChildUpdate;
    
end