function [logPsumGNoPoint,logPsumG] = getTopDownMsgs(bricks,cellParams,connChild,ruleStruct,cellMapStruct)
    
    % only on bricks can be parents
    nBricks = size(bricks,2);
    isOn = getOn(bricks)==1;
 
    pSumG = zeros(nBricks,1);
    logPsumGNoPoint = cell(cellParams.nTypes,1);
    for (n=1:cellParams.nTypes)
        logPsumGNoPoint{n} = zeros(size(cellParams.centres{n},1),nBricks);
    end

    for (k=1:nBricks)
        if(~isOn(k))
            pSumG(k) = 1; % special rule says it points to nothing
            continue;
        end
        
        typeUse = getType(bricks,k);
        locIdxUse = getLocIdx(bricks,k);
        centre = cellParams.centres{typeUse}(locIdxUse,:);
        
        slotsAvailable = connChild{k} == 0;
        slotsFilled = find(connChild{k} ~= 0);
        
        % dont use bricksOn, fucks up connChild{i} indexing
        ruleInds = find(getCompatibleRules(typeUse,connChild{k},bricks,ruleStruct)==1);

        brickNoPoint = cell(cellParams.nTypes,1);
        for (n=1:cellParams.nTypes)
            brickNoPoint{n} = zeros(size(cellParams.centres{n},1),1);
        end
        
        for (r=1:numel(ruleInds))
            
            ruleInd = ruleInds(r);
            
            probFilled = 1; %p(r_i)*(prod_{k. s.t g_{i,k} != empty}  p(g_{i,k} | r))
            for (s=1:numel(slotsFilled))

                % use  bricks, not bricksOn, so can adjust for active bricks having 0 prob of being pointed to now
                %[~,probMapNoAdjust] = adjustProbMap(probMapCells,slotType,ruleInd,slotsFilled(s),bricks,locIdxUse); % specific parent brick
                probMap = getProbMapTopDown(cellMapStruct,cellParams,ruleInd,slotsFilled(s),centre);
                
                brickFilledId = connChild{k}(slotsFilled(s));
                brickFilledIdx = getLocIdx(bricks,brickFilledId);
                
                probFilled = probFilled*probMap(brickFilledIdx);
            end
            pSumG(k) = pSumG(k) + ruleStruct.probs(ruleInd)*probFilled;
            
            brickNoPointTemp = cell(cellParams.nTypes,1);
            for (n=1:cellParams.nTypes)
                brickNoPointTemp{n} = ones(size(cellParams.centres{n},1),1);
            end
            
            slotsUse = find(((ruleStruct.children(ruleInd,:) ~= 0) & slotsAvailable) == 1);
            for (s=1:numel(slotsUse))
                % use  bricks, not bricksOn, so can adjust for active bricks having 0 prob of being pointed to now
                chType = ruleStruct.children(ruleInd,slotsUse(s));
                
                %probMap = adjustProbMap(probMapCells,slotType,ruleInd,slotsUse(s),bricks,locIdxUse);
                [temp,massInds] = getProbMapTopDown(cellMapStruct,cellParams,ruleInd,slotsUse(s),centre);
                probMap = adjustProbMap(temp,massInds,chType,bricks);    
                
                brickNoPointTemp{chType} = brickNoPointTemp{chType}.*(1-probMap);
            end
            
            for (n=1:cellParams.nTypes)
                brickNoPoint{n} = brickNoPoint{n} + ruleStruct.probs(ruleInd)*probFilled*brickNoPointTemp{n};
            end

        end
        
        for (n=1:cellParams.nTypes)
            logPsumGNoPoint{n}(:,k) = log(brickNoPoint{n});
        end
    end
    logPsumG = log(pSumG);
end