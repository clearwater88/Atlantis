function doBP(testData,posesStruct,likePxIdxCells,cellMapStruct,cellParams,params,ruleStruct,templateStruct)

    nTypes = numel(cellParams.coords);
    nBricksType = zeros(nTypes,1);
    for (n=1:nTypes)
       nBricksType(n) = size(cellParams.coords{n},1);
    end
    nRules = size(ruleStruct.rules,1);
    maxSlots = size(ruleStruct.children,2);

    % allocate space for top-down messages
    uFb1ToSb = zeros(sum(nBricksType),1); %store sb = 0
    % uSbToFb2 = uFb1ToSb
    uFb2ToRb = zeros(sum(nBricksType),nRules); % inefficient space. Storing ALL rules for each brick. This should not be memory bottlebeck.
    % uRbToFb3 = uFb2ToRb
    uFb3ToGbk = zeros(sum(nBricksType),maxSlots);
    
    % allocate space for bottom-up messages
    uGbkFb3 = zeros(sum(nBricksType),maxSlots);
    
    uFb3Rb3 = zeros(sum(nBricksType),nRules);
    %uRbToFb2 = uFb3Rb3;
    uFb2ToSb = zeros(sum(nBricksType),1);
    %uSbFb1 = uFb2ToSb;
    
    gBkLookUp = cell(nTypes,maxSlots);
    %tells where to look up inds of each type
    % typeInds(1,n2,n,k) means "tell me where do the entries in gBkLookUp{n,k} 
    % for children of type n2 start"?
    typeInds = -1*ones(2,nTypes,nTypes,maxSlots);
    refPoints = zeros(2,nTypes); % in parent coords
    
    
    for(n=1:nTypes)
        r = find(ruleStruct.parents==n,1,'last');
        refPoints(:,n) = cellMapStruct.refPoints(:,r);
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
                                     uint32([chType*ones([size(locs,1),1]), locs]));
                end
                
            end
            gBkLookUp{n,k} = unique(tempLookUp,'rows')';
            for (n2=1:nTypes)
                if(isempty(gBkLookUp{n,k})) continue; end;
                
                temp = find(gBkLookUp{n,k}(1,:)==n2,1,'first');
                if (~isempty(temp))typeInds(1,n2,n,k) = temp; end;
                temp = find(gBkLookUp{n,k}(1,:)==n2,1,'last');
                if (~isempty(temp))typeInds(2,n2,n,k) = temp; end;
            end
        end
    end
    
    conversions = zeros(2,nTypes,nTypes);
    for n=1:nTypes
        for n2=1:nTypes
            conversions(:,n,n2) = cellParams.strides(n,1:2) ./ cellParams.strides(n2,1:2);
        end
    end
    
    shiftGbkInds(gBkLookUp{1,2});
    
end