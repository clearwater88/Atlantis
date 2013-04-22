function [state,connPar,connChild] = sampleParents(brickIdx,bricks,connChild,connPar,ruleStruct,allProbMapCells,likeIm,countsIm,likePxStruct,cellParams,params)

    childType = getType(brickIdx,bricks);
    childLocIdx = getLocIdx(brickIdx,bricks);
    childCentre = cellParams.centres{childType}(childLocIdx,:);
    
    childLikes = likePxStruct.likes{childType};
    childCounts = likePxStruct.counts{childType};
    childBounds = likePxStruct.boundaries{childType};
    
    [connect,noConnect,slotProbs] = sampleParentsProbs(brickIdx, bricks,connChild,ruleStruct,allProbMapCells);
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
    
    temp = prod(connect+noConnect) - partialProbNoConnect;
    probOptions(3,1) = log(temp) + cellLogLike;

    probOptions = exp(probOptions - logsum(probOptions,1));
    probOptions = probOptions/sum(probOptions) % fucking matlab
    
    optionId = find(mnrnd(1,probOptions)==1)
    
    switch(optionId)
        case 1
            state = 0;
        case 2
            state = 1;
        case 3
            state = 1;
            [connPar,connChild] = doSample(brickIdx,connect,noConnect,connChild,connPar,slotProbs,probOptions,cellLogLike,partialProbNoConnect,params);
        otherwise
            error('Bad optionId');
    end
end

function [connPar,connChild] = doSample(brickIdx,connect,noConnect,connChild,connPar,slotProbs,probOptions,cellLogLike,probNoConnect,params)

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

% computes \sum_{rules} P(parent rule), and 
% \sum_{rules} P(parent rule) * \sum_{cell_locs} P(cell loc |
% parent rule), assuming child indicated by brickIdx is child NOT to be
% connected, and connected, respevtively connected.
% validMask masks things that could, in theory, be parents
function [connect,noConnect,slotProbs] = sampleParentsProbs(brickIdx, bricks,connChild,ruleStruct,allProbMapCells)

    nParents = size(bricks,2)-1; %last elem is the brick itself

    childType = getType(brickIdx,bricks);
    childLoc = getLocIdx(brickIdx,bricks);

    connect = zeros(nParents,1);
    noConnect = zeros(nParents,1);
    
    slotProbs = zeros(numel(ruleStruct.parents),ruleStruct.maxChildren,nParents);
    
    for (parentId=1:nParents)
         %brick off? then can't be parent
        if(bricks(1,parentId) == 0) 
            noConnect(parentId) = 1;
            connect(parentId) = 0;
            continue;
        end;

        parentLocIdx = getLocIdx(parentId,bricks);
        parentType = getType(parentId,bricks);
        slotsAvailable = (connChild{parentId} == 0);

        
        ruleInds = find(getCompatibleRules(parentType,connChild{parentId},bricks,ruleStruct)==1);
        

        noConnect(parentId) = noConnect(parentId) + sum(ruleStruct.probs(ruleInds));
        
        for (r=1:numel(ruleInds))
            ruleInd = ruleInds(r);
            
            ruleChildren = ruleStruct.children(ruleInd,:);
            % where can thsi child go?
            validSlots = find(slotsAvailable & (ruleChildren == childType));

            for (s=1:numel(validSlots))
                probMapCellUse = adjustProbMap(allProbMapCells,ruleInd,validSlots(s),parentLocIdx,bricks);
                probMap = probMapCellUse;

                slotProbs(ruleInd,validSlots(s),parentId) = ruleStruct.probs(ruleInd)*(1/numel(validSlots))*probMap(childLoc);
            end
        end
        temp = slotProbs(:,:,parentId);
        connect(parentId) = connect(parentId) + sum(temp(:));
    end
    
end