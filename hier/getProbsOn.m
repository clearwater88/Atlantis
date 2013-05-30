function [logProbOptions,noConnectParent,parentSlotProbs] = getProbsOn(type,locIdx,bricks,connChild,connPar,ruleStruct,probMapCells,likeIm,countsIm,likePxStruct,cellParams,params,logProbOptionsAll)
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
    [PsumGNoPoint,PsumG,parentSlotProbs] = sampleParentProbs(type, locIdx, bricks,connChild,ruleStruct,probMapCells);
    logsumPsumG = sum(log(PsumG));
    logsumPsumGNoPoint = sum(log(PsumGNoPoint));
    noConnectParent = PsumGNoPoint./PsumG;
    
    logDiff = log(exp(logsumPsumG-logsumPsumGNoPoint)-1) + logsumPsumGNoPoint;
    
    fromParentUpdate = [logsumPsumGNoPoint; ...
                        logsumPsumGNoPoint; ...
                        logDiff];
    logProbOptions = logProbOptions + fromParentUpdate;
    
    % bottom-up messages
    noConnectChild = sampleChildProbs(type,locIdx, bricks,ruleStruct,probMapCells);
    selfRootMask = isSelfRooted(bricks,connPar);
    nSelfRoot = sum(selfRootMask);
    
    if(~isempty(selfRootMask))
        connectOrphan = (1-noConnectChild).*selfRootMask;
        expectedChild = sum(connectOrphan);
    else
        expectedChild = 0;
    end
    

    fromChildUpdate = [nSelfRoot*log(params.probRoot); ...
                       nSelfRoot*log(params.probRoot) - (nSelfRoot-expectedChild)*log(params.probRoot); ...
                       nSelfRoot*log(params.probRoot) - (nSelfRoot-expectedChild)*log(params.probRoot)];
    logProbOptions = logProbOptions+ fromChildUpdate;
    
    [logProbOptionsAll(locIdx,:)', logProbOptions]
    
end