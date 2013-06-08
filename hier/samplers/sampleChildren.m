function [connChild,connPar] = sampleChildren(parentId,allProbMaps,bricks,ruleStruct,connChild,connPar,params)
   
    parentType = bricks(2,parentId);
    ruleMask = getCompatibleRules(parentType,connChild{parentId},bricks,ruleStruct)==1;
    ruleId = find(mnrnd(1,ruleStruct.probs.*ruleMask)==1);
    
    nSlots = sum(ruleStruct.children(ruleId,:)~=0);
    connChild{parentId} = zeros(1,ruleStruct.maxChildren);
    
    for (i=1:nSlots)
        chType = ruleStruct.children(ruleId,i);
        % access allProbMaps with probMap{ruleId,slot,loc index}

        probMap = allProbMaps{ruleId,i,bricks(3,parentId)};
        % modify with rooting probs for children who would no longer have
        % to root themselves
        % child may no longer root itself, if pointed to by previous slot.
        % if brick is not there, assume if we don't point, no one will
        % (off)
        selfRoot = isSelfRooted(bricks,connPar);
        selfRootIdx = find((selfRoot & (getType(bricks)==chType)) == 1);
        
        selfRootLocs = getLocIdx(bricks,selfRootIdx);

        probMap(selfRootLocs) = probMap(selfRootLocs).*(1/params.probRoot);
        probMap = probMap/sum(probMap);
        
        childLoc = find(mnrnd(1,probMap)==1);  
        
        childId = find((getOn(bricks) == 1) & ... % brick on
                       (getType(bricks) == chType) & ... % brick is right type
                       (getLocIdx(bricks) == childLoc) ==1,1,'first'); % brick is in right location
                   
        if(~isempty(childId))
            display(['Connecting parent: ', int2str(parentId), ' to child: ',int2str(childId), ' in sampleChildren']);
            connChild{parentId}(i) = childId;
            connPar{childId} = [connPar{childId},parentId];
        end
    end
end




