function [childMessage,nBricksOnSelfRoot] = getBottomUpMsgs(bricks,cellParams,connPar,ruleStruct,probMapCells,params)
    
    % only on bricks can be children
    isOn = getOn(bricks)==1;    
    % only self-rooted bricks will care if they get a parent
    selfRoot = isSelfRooted(bricks,connPar)==1;
    
    bricksOnSelfRoot = bricks(:,isOn & selfRoot);
    nBricksOnSelfRoot = size(bricksOnSelfRoot,2);
        
    onSelfRootIdx = getLocIdx(bricksOnSelfRoot);
    onSelfRootType = getType(bricksOnSelfRoot);
    
    childSum = cell(cellParams.nTypes,cellParams.nTypes);
    for (n=1:cellParams.nTypes)
        childSum{n} = zeros(size(cellParams.centres{n},1),1);
    end

    for (r=1:size(ruleStruct.rules,1))
        
        noConnectRule = cell(cellParams.nTypes,cellParams.nTypes);
        for (n=1:cellParams.nTypes)
            for (m=1:cellParams.nTypes)
                nChild = numel(onSelfRootIdx(onSelfRootType == m));
                %nChild = size(cellParams.centres{m},1);
                noConnectRule{n,m} = ones(size(cellParams.centres{n},1),nChild);
            end
        end
        
        slots = find(ruleStruct.children(r,:)~=0);
        parentType = ruleStruct.parents(r);
        for (j=1:numel(slots))
            s = slots(j);
            childType = ruleStruct.children(r,s);
            idxUse = onSelfRootIdx(onSelfRootType == childType);
            
            probMap = adjustProbMap(probMapCells,r,s,bricks); % use bricks for adjustment of probMap
            probMap = probMap(idxUse,:)'; % reshape to number of types at this parent level x numel(idxUse)
            %probMap = probMap';
            
            noConnectRule{parentType,childType} = noConnectRule{parentType,childType}.*(1-probMap);
        end
        
        for (n=1:cellParams.nTypes)
            temp=1-cell2mat(noConnectRule(n,:));
            childSum{n} = childSum{n} + ruleStruct.probs(r)*sum(temp,2);
        end
    end
    
    childMessage = cell(cellParams.nTypes,1);
    
    for (n=1:cellParams.nTypes)
        childMessage{n} = nBricksOnSelfRoot*log(params.probRoot)-(nBricksOnSelfRoot-childSum{n})*log(params.probRoot);
    end
    
end

