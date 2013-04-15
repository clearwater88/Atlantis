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
            
            % brick in active set? Then we say we can't be its
            % parent, since we already decided on that. Except brick we're
            % on.
            active = isInActiveSet(bricks,chType,numel(probMap))==1;
            active(chLoc) = 0;
            probMap(active) = 0;
            probMap = probMap/sum(probMap);
            
            probSlotsNo = probSlotsNo*(1-probMap(chLoc));
            mm = max(probMap(chLoc),mm);
        end
        probNo = probNo + ruleProb*probSlotsNo;
    end
    % normalize to set of possible rules
    probNo = probNo / sum(ruleStruct.probs(ruleInds));

end

