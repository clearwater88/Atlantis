function [noConnect] = sampleChildProbs(parentType, parentLocIdx, bricks,ruleStruct,allProbMapCells)
    ruleInds = find(ruleStruct.parents==parentType);
    nBricks = size(bricks,2);
    
    noConnect = zeros(1,nBricks);
    ruleSum = sum(ruleStruct.probs(ruleInds)); % should be 1
    for (r=1:numel(ruleInds))
        ruleInd = ruleInds(r);
            
        ruleChildren = ruleStruct.children(ruleInd,:);
        
        nValidSlots = sum(ruleChildren~=0);
        
        probNoPoint = ones(1,nBricks);
        
        for (s=1:nValidSlots)
           chType = ruleChildren(s); 
           childBrickIdx = find(getType(bricks)==chType & getOn(bricks)==1);
           
           if(isempty(childBrickIdx))
               continue;
           end
           
           childBrickLocIdx = getLocIdx(bricks,childBrickIdx);
           
           probMap = adjustProbMap(allProbMapCells,ruleInd,s,bricks,parentLocIdx);
           childProbs = probMap(childBrickLocIdx)';
           
           probNoPoint(childBrickIdx) = probNoPoint(childBrickIdx).*(1-childProbs);
               
        end
        noConnect = noConnect+(ruleStruct.probs(ruleInd)/ruleSum)*probNoPoint;
    end
end