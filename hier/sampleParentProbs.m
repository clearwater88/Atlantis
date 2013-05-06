function [noConnect,slotProbs] = sampleParentProbs(childType, childLoc, bricks,connChild,ruleStruct,allProbMapCells)
    % computes P(become parent) for each brick.
    % noConnect: 1-P(become parent) (or it should be; do actual computation
    %            for sanity check)

    nParents = size(bricks,2)-1; %last elem is the brick itself
    noConnect = zeros(nParents,1);
    
    slotProbs = zeros(numel(ruleStruct.parents),ruleStruct.maxChildren,nParents);
    
    for (parentId=1:nParents)
         %brick off? then can't be parent
        if(bricks(1,parentId) == 0) 
            noConnect(parentId) = 1;
            continue;
        end;

        parentLocIdx = getLocIdx(bricks,parentId);
        parentType = getType(bricks,parentId);
        slotsAvailable = (connChild{parentId} == 0);

        ruleInds = find(getCompatibleRules(parentType,connChild{parentId},bricks,ruleStruct)==1);
        ruleProbSum = sum(ruleStruct.probs(ruleInds));

        for (r=1:numel(ruleInds))
            ruleInd = ruleInds(r);
            
            ruleChildren = ruleStruct.children(ruleInd,:);
            % where can this child go?
            validSlots = find(slotsAvailable & (ruleChildren == childType));

            probNoPoint = 1;
            for (s=1:numel(validSlots))
                probMap = adjustProbMap(allProbMapCells,ruleInd,validSlots(s),parentLocIdx,bricks);

                slotProbs(ruleInd,validSlots(s),parentId) = ruleStruct.probs(ruleInd)*probMap(childLoc);
                probNoPoint = probNoPoint*(1-probMap(childLoc)); % P(noConnect|r)
            end
            noConnect(parentId) = noConnect(parentId)+(ruleStruct.probs(ruleInd)/ruleProbSum)*probNoPoint;
        end
    end
    % connect+noConnect %hsould sum to 1
    % [connect,noConnect]
    
end