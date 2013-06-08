function [connChild,connPar] = sampleParents(brickIdx,connChild,connPar,noConnect,slotProbs)

    % rejection sampling. Determine parent first
    while(1)
        isChild = rand(numel(noConnect),1) > noConnect;
        if (sum(isChild) > 0)
            break;
        end
    end

    inds = find(isChild == 1);
    
    % now sample appropriate slots
    for (i=1:numel(inds))
        id = inds(i);
        slotProb = slotProbs(:,:,id);
        slotProb = sum(slotProb,1)/sum(slotProb(:));
        slot = find(mnrnd(1,slotProb)==1);
        assert(connChild{id}(slot) == 0);
        connChild{id}(slot) = brickIdx;
        
        display(['Connect parent: ', int2str(id), ' to child: ', int2str(brickIdx), ' in sampleParents']);
        connPar{brickIdx} = [connPar{brickIdx},id];
    end
    
end


