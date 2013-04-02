function conn = sampleParents(childId,bricks,conn,ruleStruct,allProbMaps)

    for (parentId=1:size(bricks,2))
        if(parentId==childId) continue; end;
        if(bricks(1,parentId) == 0) continue; end; %brick off? then can't be parent

        [probNo] = probBecomeParent(childId,parentId,bricks,conn,ruleStruct,allProbMaps);

        if (probNo > rand(1,1)) continue; end;

        tic
        %Decided to make connection. Need to decide on probs and shit
        parentId

        chType = bricks(2,childId);
        chLoc = bricks(3,childId);
        parentLoc = bricks(3,parentId);
        
        parentConn = conn{parentId};
        slotsAvailable = (parentConn == 0);

        ruleInds = find(getCompatibleRules(parentId,parentConn,bricks,ruleStruct)==1);
        slotProbs = zeros(numel(ruleStruct.parents),ruleStruct.maxChildren);

        for (r=1:numel(ruleInds))
            ruleInd = ruleInds(r);
            ruleProb = ruleStruct.probs(ruleInd);

            ruleChildren = ruleStruct.children(ruleInd,:);
            validSlots = find(slotsAvailable & (ruleChildren == chType));

            for (s=1:numel(validSlots))
                probMap = allProbMaps{ruleInd,validSlots(s),parentLoc};
                slotProbs(ruleInd,validSlots(s)) = ruleProb*probMap(chLoc);
            end
        end
        slotProbs = slotProbs/sum(slotProbs(:));
        slotProbs = sum(slotProbs,1);
        slotUse = find(mnrnd(1,slotProbs')==1);
        conn{parentId}(slotUse) = childId;
        toc
    end
end

