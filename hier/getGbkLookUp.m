function [gBkLookUp,refPoints,typeInds] = getGbkLookUp(nTypes,maxSlots,ruleStruct,cellMapStruct)

    % possible children of each brick. Incorporates all rules

    nRules = size(ruleStruct.rules,1);

    gBkLookUp = cell(nTypes,maxSlots);
    %tells where to look up inds of each type
    % typeInds(1,n2,n,k) means "tell me where the entries in gBkLookUp{n,k} 
    % for children of type n2 start"?
    typeInds = -1*ones(2,nTypes,nTypes,maxSlots);
    refPoints = zeros(2,nTypes); % in parent coords
    
    for(n=1:nTypes)
        r = find(ruleStruct.parents==n,1,'last');
        if(isempty(cellMapStruct.refPoints))
            refPoints(:,n) = [-1,-1]'; % no context hack
        else
            refPoints(:,n) = cellMapStruct.refPoints(:,r);
        end
    end
    
    % make look up tables. Guaranteed that looking at a slot, and going in
    % order of rules, types are grouped together. eg: [0,1,1,2,2], but not
    % [0,1,2,1,2]; Allows for indexing of the lookups
    for (n=1:nTypes)
        for (k=1:maxSlots)
            tempLookUp = [];
            for (r=1:nRules)
                if (ruleStruct.parents(r)~= n) continue; end;
                if (ruleStruct.children(r,k) == 0) continue; end;
                chType = ruleStruct.children(r,k);
                for (agInd = 1:size(cellMapStruct.locs,3))
                    locs = cellMapStruct.locs{r,k,agInd};
                    tempLookUp = cat(1, ...
                                     tempLookUp, ...
                                     [chType*ones([size(locs,1),1]), locs]);
                end 
            end
            [~,b] =unique(tempLookUp,'rows','first');
            % insure if tempLookUp entries are in raster order, they stay
            % in raster order
            gBkLookUp{n,k} = tempLookUp(sort(b),:)'; % sort(b) because matlab is dumb
            for (n2=1:nTypes)
                if(isempty(gBkLookUp{n,k})) continue; end;
                
                temp = find(gBkLookUp{n,k}(1,:)==n2,1,'first');
                if (~isempty(temp))typeInds(1,n2,n,k) = temp; end;
                temp = find(gBkLookUp{n,k}(1,:)==n2,1,'last');
                if (~isempty(temp))typeInds(2,n2,n,k) = temp; end;
            end
        end
    end
end