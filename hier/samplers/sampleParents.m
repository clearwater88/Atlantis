function [connect,noConnect] = sampleParents(brickIdx, bricks,connChild,ruleStruct,allProbMapCells)
    [connect,noConnect] = sampleParentsProbs(brickIdx, bricks,connChild,ruleStruct,allProbMapCells)
end

% prob of each parent being connect/not connect
function [connect,noConnect] = sampleParentsProbs(brickIdx, bricks,connChild,ruleStruct,allProbMapCells)

    nParents = size(bricks,2);

    childType = getType(brickIdx,bricks);
    childLoc = getLocIdx(brickIdx,bricks);

    connect = zeros(nParents,1);
    noConnect = zeros(nParents,1);
    
    for (parentId=1:nParents)
        if(parentId==brickIdx) continue; end;
        if(bricks(1,parentId) == 0) continue; end; %brick off? then can't be parent

        parentLocIdx = getLocIdx(parentId,bricks);
        parentType = getType(parentId,bricks);
        slotsAvailable = (connChild{parentId} == 0);

        
        ruleInds = find(getCompatibleRules(parentType,connChild{parentId},bricks,ruleStruct)==1);
        slotProbs = zeros(numel(ruleStruct.parents),ruleStruct.maxChildren);

        noConnect(parentId) = noConnect(parentId) + sum(ruleStruct.probs(ruleInds));
        
        for (r=1:numel(ruleInds))
            ruleInd = ruleInds(r);
            
            ruleChildren = ruleStruct.children(ruleInd,:);
            % where can thsi child go?
            validSlots = find(slotsAvailable & (ruleChildren == childType));

            for (s=1:numel(validSlots))
                probMapCellUse = adjustProbMap(allProbMapCells,ruleInd,validSlots(s),parentLocIdx,bricks);
                probMap = probMapCellUse;

                slotProbs(ruleInd,validSlots(s)) = ruleStruct.probs(ruleInd)*probMap(childLoc);
            end
        end
        connect(parentId) = connect(parentId) + sum(slotProbs(:));
    end
end