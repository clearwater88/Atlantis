function [connChild,connPar] = sampleChildren(parentId,allProbMaps,bricks,ruleStruct,connChild,connPar,params)
    
    parentType = bricks(2,parentId);
    ruleMask = getCompatibleRules(parentType,connChild{parentId},bricks,ruleStruct)==1;
    ruleId = find(mnrnd(1,ruleStruct.probs.*ruleMask)==1);
    
    nSlots = sum(ruleStruct.children(ruleId,:)~=0);
    connChild{parentId} = zeros(1,ruleStruct.maxChildren);
    
    for (i=1:nSlots)
        chType = ruleStruct.children(ruleId,i);
        % access allProbMaps with probMap{ruleId,slot,loc index}

        probMapPrior = allProbMaps{ruleId,i,bricks(3,parentId)};
        % modify with rooting probs for children who would no longer have
        % to root themselves
        [selfRootMask] = isSelfRooted(bricks,chType,connPar,numel(probMapPrior));
        probMap = probMapPrior.*((1/params.probRoot(chType)).^selfRootMask);
        probMap = probMap/sum(probMap);
        
        childLoc = sampleChild(probMap);     
        
        childId = find((bricks(1,:) == 1) & ... % brick on
                       (bricks(2,:) == chType) & ... % brick is right type
                       (bricks(3,:) == childLoc) ==1,1,'first'); % brick is in right location
                   
        if(~isempty(childId))
            display(['Connecting parent: ', int2str(parentId), ' to child: ',int2str(childId), ' in sampleChildren']);
            connChild{parentId}(i) = childId;
            connPar{childId} = [connPar{childId},parentId];
        end
    end
end

function res = sampleChild(probMap)
    res=find(mnrnd(1,probMap)==1);
end



