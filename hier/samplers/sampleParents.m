function [connect,noConnect] = sampleParents(brickIdx, bricks,connChild,connPar,ruleStruct,allProbMapCells)

    childType = getType(brickIdx,bricks);
    childLoc = getLocIdx(brickIdx,bricks);
    
    
    for (parentId=1:size(bricks,2))
        if(parentId==brickIdx) continue; end;
        if(bricks(1,parentId) == 0) continue; end; %brick off? then can't be parent
        
        parentLocIdx = getLocIdx(parentId,bricks);
        slotsAvailable = (connChild{parentId} == 0);
        
        ruleInds = find(getCompatibleRules(parentId,connChild{parentId},bricks,ruleStruct)==1);
        slotProbs = zeros(numel(ruleStruct.parents),ruleStruct.maxChildren);

        for (r=1:numel(ruleInds))
            ruleInd = ruleInds(r);
            ruleProb = ruleStruct.probs(ruleInd);

            ruleChildren = ruleStruct.children(ruleInd,:);
            % where can thsi child go?
            validSlots = find(slotsAvailable & (ruleChildren == childType));

            
            for (s=1:numel(validSlots))
                probMap = allProbMapCells{ruleInd,validSlots(s),parentLocIdx};
                slotProbs(ruleInd,validSlots(s)) = ruleProb*probMap(childLoc);
            end
        end
        
    end
end

