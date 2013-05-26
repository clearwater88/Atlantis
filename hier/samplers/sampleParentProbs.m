function [PsumGNoPoint,PsumG,slotProbs] = sampleParentProbs(childType, childLoc, bricks,connChild,ruleStruct,allProbMapCells)
    % computes 2 quanitities for become a parent of brick a. The quantities
    % are:
    %
    % PsumGPoint:
    % \sum_{r_i} p(r_i)*(prod_{k. s.t g_{i,k} != empty} p(g_{i,k} | r))*(prod_{k. s.t g_{i,k} == empty} (1-p(g_{i,k} = a | r)) \foreach i
    %
    % and
    %
    % PsumG:
    % \prod_i \sum_{r_i} p(r_i)*(prod_{k. s.t g_{i,k} != empty} p(g_{i,k} | r))  \foreach i
    %
    % Note that for computing saliency, we really just need the ratio of
    % these terms, which would simplify computation. But let's do it this
    % way for now, since the ratio thing is harder to get right.

    nParents = size(bricks,2)-1; %last elem is the brick itself
    
    PsumGNoPoint = zeros(nParents,1);
    PsumG = zeros(nParents,1);
    
    slotProbs = zeros(numel(ruleStruct.parents),ruleStruct.maxChildren,nParents);
    ruleProbSum = ones(nParents,1);
    for (parentId=1:nParents)
         %brick off? then can't be parent, and r_i = "no child" rule
        if(bricks(1,parentId) == 0) 
            PsumGNoPoint(parentId) = 1;
            PsumG(parentId) = 1;
            continue;
        end;

        parentLocIdx = getLocIdx(bricks,parentId);
        parentType = getType(bricks,parentId);
        slotsAvailable = (connChild{parentId} == 0);

        % get rules compatible with current children config
        ruleInds = find(getCompatibleRules(parentType,connChild{parentId},bricks,ruleStruct)==1);
        ruleProbSum(parentId) = sum(ruleStruct.probs(ruleInds));

        for (r=1:numel(ruleInds))
            ruleInd = ruleInds(r);
            
            ruleChildren = ruleStruct.children(ruleInd,:);
            % where can this child go?
            validSlots = find(slotsAvailable & (ruleChildren == childType));
            filledSlots = find(~slotsAvailable);
            
            probNoPoint = 1; %(prod_{k. s.t g_{i,k} == empty} (1-p(g_{i,k} = a | r))
            for (s=1:numel(validSlots))
                probMap = adjustProbMap(allProbMapCells,ruleInd,validSlots(s),parentLocIdx,bricks);

                slotProbs(ruleInd,validSlots(s),parentId) = ruleStruct.probs(ruleInd)*probMap(childLoc);
                probNoPoint = probNoPoint*(1-probMap(childLoc)); % P(noConnect|r)
            end
            
            probFilled = 1; %p(r_i)*(prod_{k. s.t g_{i,k} != empty}  p(g_{i,k} | r))
            for (s=1:numel(filledSlots))
                probMap = adjustProbMap(allProbMapCells,ruleInd,filledSlots(s),parentLocIdx,bricks);

                brickFilledId = connChild{parentId}(filledSlots(s));
                brickFilledIdx = getLocIdx(bricks,brickFilledId);
                
                probFilled = probFilled*probMap(brickFilledIdx);
            end
            PsumGNoPoint(parentId) = PsumGNoPoint(parentId)+ruleStruct.probs(ruleInd)*probFilled*probNoPoint;
            PsumG(parentId) =        PsumG(parentId)       +ruleStruct.probs(ruleInd)*probFilled;
            
            %noConnect(parentId) = noConnect(parentId)+(ruleStruct.probs(ruleInd)/ruleProbSum(parentId))*probFilled*probNoPoint;
        end
    end
end