function [logPsumGNoPoint,logPsumG] = getTopDownMsgs(bricks,cellParams,connChild,ruleStruct,probMapCells)
    
    % only on bricks can be parents
    isOn = getOn(bricks)==1;
    bricksOn = bricks(:,isOn);
    nBricksOn = size(bricksOn,2);
    
    pSumG = zeros(nBricksOn,1);
    logPsumGNoPoint = cell(cellParams.nTypes,1);
    for (n=1:cellParams.nTypes)
        logPsumGNoPoint{n} = zeros(size(cellParams.centres{n},1),1);
    end
        
    for (i=1:nBricksOn)
        
        typeUse = getType(bricksOn,i);
        locIdxUse = getLocIdx(bricksOn,i);
        
        slotsAvailable = connChild{i} == 0;
        slotsFilled = find(connChild{i} ~= 0);
        
        % dont use bricksOn, fucks up connChild{i} indexing
        ruleInds = find(getCompatibleRules(typeUse,connChild{i},bricks,ruleStruct)==1);

        brickNoPoint = cell(cellParams.nTypes,1);
        for (n=1:cellParams.nTypes)
            brickNoPoint{n} = zeros(size(cellParams.centres{n},1),1);
        end
        
        for (r=1:numel(ruleInds))
            
            ruleInd = ruleInds(r);
            
            probFilled = 1; %p(r_i)*(prod_{k. s.t g_{i,k} != empty}  p(g_{i,k} | r))
            for (s=1:numel(slotsFilled))
                % use  bricks, not bricksOn, so can adjust for active bricks having 0 prob of being pointed to now
                probMap = adjustProbMap(probMapCells,ruleInd,slotsFilled(s),bricks,locIdxUse);

                brickFilledId = connChild{i}(slotsFilled(s));
                brickFilledIdx = getLocIdx(bricksOn,brickFilledId);
                
                probFilled = probFilled*probMap(brickFilledIdx); % careful with probMap modifying
            end
            pSumG(i) = pSumG(i) + ruleStruct.probs(ruleInd)*probFilled;
            
            
            brickNoPointTemp = cell(cellParams.nTypes,1);
            for (n=1:cellParams.nTypes)
                brickNoPointTemp{n} = ones(size(cellParams.centres{n},1),1);
            end
            
            slotsUse = find(((ruleStruct.children(ruleInd,:) ~= 0) & slotsAvailable) == 1);
            for (s=1:numel(slotsUse))
                % use  bricks, not bricksOn, so can adjust for active bricks having 0 prob of being pointed to now
                slotType = ruleStruct.children(ruleInd,slotsUse(s));
                probMap = adjustProbMap(probMapCells,ruleInd,slotsUse(s),bricks,locIdxUse);
                brickNoPointTemp{slotType} = brickNoPointTemp{slotType}.*(1-probMap);
            end
            
            for (n=1:cellParams.nTypes)
                brickNoPoint{n} = brickNoPoint{n} + ruleStruct.probs(ruleInd)*probFilled*brickNoPointTemp{n};
            end

        end
        
        for (n=1:cellParams.nTypes)
            logPsumGNoPoint{n} = logPsumGNoPoint{n} + log(brickNoPoint{n});
        end
        
    end
    logPsumG = sum(log(pSumG));
end