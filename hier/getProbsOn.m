function [logProbOptions,noConnectParent,parentSlotProbs] = getProbsOn(type,locIdx,bricks,connChild,connPar,ruleStruct,allProbMapCells,likeIm,countsIm,likePxStruct,cellParams,params)
    % optionId: off,on/self-root,on/with-parent

    childCentre = cellParams.centres{type}(locIdx,:);
    
    childLikes = likePxStruct.likes{type};
    childCounts = likePxStruct.counts{type};
    childBounds = likePxStruct.boundaries{type};
    
    defaultLogLikeIm = sum(log(likeIm(:)./countsIm(:)));

    ids = find(getLikePxIdx(childCentre,cellParams.dims(type,:),childBounds) == 1);
    logProbs = cellLogProbs(ids,likeIm,countsIm,childLikes,childCounts,childBounds);
    logProbs = logProbs + log(1/numel(logProbs)); %add in prior
    cellLogLike = logsum(logProbs,1);
        
    % off,on/self-root,on/with-parent
    logProbOptions(1,1) = defaultLogLikeIm + log(1-params.probRoot);
    logProbOptions(2,1) = cellLogLike + log(params.probRoot);
    logProbOptions(3,1) =  cellLogLike;
    
    % top-down messages
    [PsumGNoPoint,PsumG,parentSlotProbs] = sampleParentProbs(type, locIdx, bricks,connChild,ruleStruct,allProbMapCells);
    logsumPsumG = sum(log(PsumG));
    logsumPsumGNoPoint = sum(log(PsumGNoPoint));
    
    noConnectParent = PsumGNoPoint./PsumG;
    noConnectParent
    %pause(0.1)
    
    logDiff = log(exp(logsumPsumG-logsumPsumGNoPoint)-1) + logsumPsumGNoPoint;
    
    fromParentUpdate = [logsumPsumGNoPoint; ...
                        logsumPsumGNoPoint; ...
                        logDiff];
    logProbOptions = logProbOptions + fromParentUpdate;

    % bottom-up messages
    noConnectChild = sampleChildProbs(type,locIdx, bricks,ruleStruct,allProbMapCells);
    selfRootMask = isSelfRooted(bricks,connPar);
    nSelfRoot = sum(selfRootMask);
    
    connectOrphan = (1-noConnectChild).*selfRootMask;
    expectedChild = sum(connectOrphan);

    fromChildUpdate = [nSelfRoot*log(params.probRoot); ...
                       nSelfRoot*log(params.probRoot) - (nSelfRoot-expectedChild)*log(params.probRoot); ...
                       nSelfRoot*log(params.probRoot) - (nSelfRoot-expectedChild)*log(params.probRoot)];
    logProbOptions = logProbOptions+ fromChildUpdate;

   
    
end