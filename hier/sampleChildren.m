function [connChild,connPar,connOK] = sampleChildren(parentId,allProbMaps,bricks,ruleStruct,connChild,connPar,poseCellLocs,probRoot)
% do at creation of brick

    connOK = 0;
    ruleMask = getCompatibleRules(parentId,connPar{parentId},bricks,ruleStruct)==1;
    ruleId = find(mnrnd(1,ruleStruct.probs.*ruleMask)==1);
    
    nSlots = sum(ruleStruct.children(ruleId,:)~=0);
    
    for (i=1:nSlots)
        chType = ruleStruct.children(ruleId,i);
        % access allProbMaps with probMap{ruleId,slot,loc index}
        
        
        probMapPrior = allProbMaps{ruleId,i,bricks(3,parentId)};
        % modify with rooting probs
        [selfRootMask] = isSelfRooted(bricks,chType,connPar,numel(probMapPrior));
        probMap = probMapPrior.*((1/probRoot(chType)).^selfRootMask);
        probMap = probMap/sum(probMap);
        
        childLoc = sampleChild(probMap);     
        
        childId = find((bricks(1,:) == 1) & ... % brick on
                       (bricks(2,:) == chType) & ... % brick is right type
                       (bricks(3,:) == childLoc) ==1); % brick is in right location
                   
        if(~isempty(childId))
            display(['Connecting parent: ', int2str(parentId), ' to child: ',int2str(childId), ' in sampleChildren']);
            connChild{parentId}(i) = childId;
            connPar{childId} = [connPar{childId},parentId];
            connOK = 1;
        end
    end
end

