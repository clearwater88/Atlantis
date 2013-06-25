function [totMessage] = getBottomUpMsgs(bricks,cellParams,connPar,ruleStruct,cellMapStruct,params)
    
    nTypes = cellParams.nTypes;
    
    % only on and self-rooted bricks will care if they get a parent
    selfRoot = isSelfRooted(bricks,connPar)==1;
    
    bricksOnSelfRoot = bricks(:,selfRoot);
        
    onSelfRootIdx = getLocIdx(bricksOnSelfRoot);
    onSelfRootType = getType(bricksOnSelfRoot);

    totMessage = cell(nTypes,1);
    for (n=1:nTypes)
        totMessage{n} = zeros(size(cellParams.centres{n},1),1);
    end
    
    for (r=1:size(ruleStruct.rules,1))
        slots = find(ruleStruct.children(r,:)~=0);
        parentType = ruleStruct.parents(r);
        
        probMapProd = ones(size(cellParams.centres{parentType},1),1);
        for (j=1:numel(slots))
            probMap = [];
            
            s = slots(j);
            childType = ruleStruct.children(r,s);
            orphansIdx = onSelfRootIdx(onSelfRootType == childType);
            
            if (isempty(orphansIdx))
                probMap = zeros(0,numel(probMapProd)); % default, in case no orphans
            end
            for (k=1:numel(orphansIdx))
                centre = cellParams.centres{childType}(orphansIdx(k),:);
                [temp,massInds] = getProbMapBottomUp(cellMapStruct,cellParams,r,s,centre);
                probMap(k,:) = temp;
            end
            
            %[~,probMap] = adjustProbMap(probMapCells,childType,r,s,bricks); % use bricks for adjustment of probMap
            %probMap = probMap(orphansIdx,:); % get a specific set of children for every parent. size: numel(idxUse) x number of types of parents
            probMap = sum(probMap,1)';
            
            probMapProd = probMapProd.*(params.probRoot^(-1)*probMap + (1-probMap));
        end
        totMessage{parentType} = totMessage{parentType} + ruleStruct.probs(r)*probMapProd;
    end
    
    for (n=1:nTypes)
        totMessage{n} = log(totMessage{n});
    end
    
end



