function [res] = evalParticleLogProbPrior(bricks,connChild,connPar,ruleStruct,nPosesCell, probMapCells, params)

    nBricks = size(bricks,2);
    nOrphan = sum(isSelfRooted(bricks,connPar));
    
    % compute pose probs
    logPoseProb = 0;
    for (i=1:nBricks)
        type = getType(bricks,i);
        idx = getLocIdx(bricks,i);
        logPoseProb = logPoseProb + -log(nPosesCell{type}(idx));
    end
    
    probPoint = zeros(nBricks,1);
    for (i=1:size(bricks,2))
        type = getType(bricks,i);
        idx = getLocIdx(bricks,i);

        slots = connChild{i};
        
        ruleInds = find(getCompatibleRules(type,slots,bricks,ruleStruct)==1);
        for (r=1:numel(ruleInds))
           
           probTempSlot = 1;
           for (s=1:numel(slots))
              if(slots(s) == 0) continue; end;
              childBrickId = slots(s);
              childType = getType(bricks,childBrickId);
              childLocIdx = getLocIdx(bricks,childBrickId);
              [~,probMap] = adjustProbMap(probMapCells,childType,ruleInds(r),s,bricks);
              probTempSlot = probTempSlot*probMap(childLocIdx,idx);
           end
           probPoint(i) = probPoint(i)+ruleStruct.probs(ruleInds(r))*probTempSlot;
        end
    end
    logProbPoint = sum(log(probPoint),1);    
    res = nOrphan*log(params.probRoot) + logPoseProb + logProbPoint;
end

