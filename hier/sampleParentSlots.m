function [slotProbs] = sampleParentSlots(childType, childLoc, bricks,connChild,ruleStruct,allProbMapCells)

    nParents = size(bricks,2)-1; %last elem is the brick itself
    
    slotProbs = zeros(numel(ruleStruct.parents),ruleStruct.maxChildren,nParents);

    for (parentId=1:nParents)
         %brick off? then can't be parent, and r_i = "no child" rule
        if(bricks(1,parentId) == 0) 
            continue;
        end;

        parentLocIdx = getLocIdx(bricks,parentId);
        parentType = getType(bricks,parentId);
        slotsAvailable = (connChild{parentId} == 0);

        % get rules compatible with current children config
        ruleInds = find(getCompatibleRules(parentType,connChild{parentId},bricks,ruleStruct)==1);

        for (r=1:numel(ruleInds))
            ruleInd = ruleInds(r);
            
            ruleChildren = ruleStruct.children(ruleInd,:);
            % where can this child go?
            validSlots = find(slotsAvailable & (ruleChildren == childType));

            for (s=1:numel(validSlots))
                probMap = adjustProbMap(allProbMapCells,childType,ruleInd,validSlots(s),bricks,parentLocIdx);
                slotProbs(ruleInd,validSlots(s),parentId) = ruleStruct.probs(ruleInd)*probMap(childLoc);
            end
        end
    end
end