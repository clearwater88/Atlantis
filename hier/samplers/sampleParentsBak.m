function [state,connPar,connChild] = sampleParents(brickIdx,bricks,connChild,connPar,ruleStruct,allProbMapCells,likeIm,countsIm,likePxStruct,cellParams,params)

    childType = getType(bricks,brickIdx);
    childLocIdx = getLocIdx(bricks,brickIdx);
    childCentre = cellParams.centres{childType}(childLocIdx,:);
    
    childLikes = likePxStruct.likes{childType};
    childCounts = likePxStruct.counts{childType};
    childBounds = likePxStruct.boundaries{childType};
    
    [noConnect,slotProbs] = sampleParentProbs(brickIdx, bricks,connChild,ruleStruct,allProbMapCells);
    partialProbNoConnect = prod(noConnect);
    
    ids = find(getLikePxIdx(childCentre,cellParams.dims(childType,:),childBounds) == 1);
    
    logProbs = cellLogProbs(ids,likeIm,countsIm,childLikes,childCounts,childBounds);
    logProbs = logProbs + log(1/numel(logProbs)); %add in prior
    
    cellLogLike = logsum(logProbs,1);
    defaultLogLikeIm = sum(log(likeIm(:)./countsIm(:)));
    
    % off,on/self-root,on,with-parent
    probOptions(1,1) = log(1-params.probRoot(childType)) + log(partialProbNoConnect) + ...
                       defaultLogLikeIm;
    probOptions(2,1) = log(params.probRoot(childType)) + log(partialProbNoConnect) + cellLogLike;
    
    temp = 1 - partialProbNoConnect;
    probOptions(3,1) = log(temp) + cellLogLike;

    probOptions = exp(probOptions - logsum(probOptions,1));
    probOptions = probOptions/sum(probOptions) % fucking matlab
    
    optionId = find(mnrnd(1,probOptions)==1);
    
    switch(optionId)
        case 1
            state = 0;
        case 2
            state = 1;
        case 3
            state = 1;
            [connPar,connChild] = doSample(brickIdx,noConnect,connChild,connPar,slotProbs,probOptions,cellLogLike,partialProbNoConnect,params);
        otherwise
            error('Bad optionId');
    end
    state
end

function [connPar,connChild] = doSample(brickIdx,noConnect,connChild,connPar,slotProbs,probOptions,cellLogLike,probNoConnect,params)

    connect = 1-noConnect;
    connect = (connect)./(connect+noConnect+000000001);

    % rejection sampling
    while(1)
        isChild = rand(numel(connect,1)) <= connect;
        if (sum(isChild) > 0)
            break;
        end
    end

    inds = find(isChild == 1);
    
    for (i=1:numel(inds))
        id = inds(i);
        slotProb = slotProbs(:,:,id);
        slotProb = sum(slotProb,1)/sum(slotProb(:));
        slot = find(mnrnd(1,slotProb)==1);
        assert(connChild{id}(slot) == 0);
        connChild{id}(slot) = brickIdx;
        
        display(['Connect parent: ', int2str(id), ' to child: ', int2str(brickIdx), ' in sampleParents']);
        connPar{brickIdx} = [connPar{brickIdx},id];
    end
    
%     temp = find(connect > 0,1,'first');


end


