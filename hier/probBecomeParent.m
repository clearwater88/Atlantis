function [probNo] = probBecomeParent(childId,parentId,bricks,conn,ruleStruct,allProbMaps)

    chType = bricks(2,childId);
    chLoc = bricks(3,childId);

    parentLoc = bricks(3,parentId);
    parentConn = conn{parentId};
    ruleInds = find(getCompatibleRules(parentId,parentConn,bricks,ruleStruct)==1);

    slotsAvailable = (parentConn == 0);

    probNo = 0;
    mm = 0;
    for (r=1:numel(ruleInds))
        ruleInd = ruleInds(r);
        ruleProb = ruleStruct.probs(ruleInd);

        ruleChildren = ruleStruct.children(ruleInd,:);
        validSlots = find(slotsAvailable & (ruleChildren == chType));

        probSlotsNo = 1;
        for (s=1:numel(validSlots))
            probMap = allProbMaps{ruleInd,validSlots(s),parentLoc};
            probSlotsNo = probSlotsNo*(1-probMap(chLoc));
            mm = max(probMap(chLoc),mm);
        end
        probNo = probNo + ruleProb*probSlotsNo;
    end
end
