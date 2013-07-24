function doBP(testData,posesStruct,likePxIdxCells,cellMapStruct,cellParams,params,ruleStruct,templateStruct)

    nTypes = numel(cellParams.coords);
    nBricksType = zeros(nTypes,1);
    for (n=1:nTypes)
       nBricksType(n) = size(cellParams.coords{n},1);
    end
    maxSlots = size(ruleStruct.children,2);

    [gBkLookUp,refPoints] = getGbkLookUp(nTypes,maxSlots,ruleStruct,cellMapStruct);
    conversions = getConversions(nTypes, cellParams);
    
    % allocate space for top-down messages
    uFb1ToSb_0 = cell(nTypes,1); % only stores uFb1ToSb=0
    uFb2ToRb = cell(nTypes,1); % stores all values
    uFb3ToGbk = cell(nTypes,maxSlots);
    for (i=1:nTypes)
        uFb1ToSb_0{i} = 0.01 + 0.005*rand(nBricksType(i),1);
           
        uFb2ToRb{i} = 0.01 + 0.005*rand(nBricksType(i),sum(ruleStruct.parents== i));
        uFb2ToRb{i} = bsxfun(@rdivide, uFb2ToRb{i}, sum(uFb2ToRb{i},2));
        
        for (k=1:maxSlots)
             %who messages are intended for given by gBkLookUp.
             % 1+ is for null (no point)
            uFb3ToGbk{i,k} = 0.01 + 0.005*rand(nBricksType(i),1+size(gBkLookUp{i,k},2));
            uFb3ToGbk{i,k} = bsxfun(@rdivide, uFb3ToGbk{i,k}, sum(uFb3ToGbk{i,k},2));
        end
    end
    % uSbToFb2 = uFb1ToSb
    % uRbToFb3 = uFb2ToRb

    
    % allocate space for bottom-up messages
    uGbkFb3 = cell(nTypes,maxSlots);
    uRbToFb2 = cell(nTypes,1); % stores all values
    uSbToFb1_0 = cell(nTypes,1); % only stores uFb1ToSb=0
    for (i=1:nTypes)
        for (k=1:maxSlots)
            uGbkFb3{i,k} = 0.01 + 0.005*rand(nBricksType(i),1+size(gBkLookUp{i,k},2));
        end
        
        uRbToFb2{i} = 0.01 + 0.005*rand(nBricksType(i),sum(ruleStruct.parents== i));
        uRbToFb2{i} = bsxfun(@rdivide, uRbToFb2{i}, sum(uRbToFb2{i},2));
        
        uSbToFb1_0{i} = 0.01 + 0.005*rand(nBricksType(i),1);
    end
    %uFb3Rb3 = uRbToFb2;
    %uFb2ToSb = uSbFb1_0;

    while(1)
        %% down pass
        % compute uFb2ToRb
        tic
        for (i=1:nTypes)
            ruleIds = ruleStruct.parents==i;
            probs = ruleStruct.probs(ruleIds)';
            
            temp = zeros(nBricksType(i), numel(probs));
            temp(:,1) = uFb1ToSb_0{i}; % stores P(rb|sb=0)m_{sb->fb2}(sb)
            temp = bsxfun(@times, (1-uFb1ToSb_0{i}), probs) + temp;
            uFb2ToRb{i} = bsxfun(@rdivide,temp,sum(temp,2));
        end
        toc
        %% down pass
        
        %% up pass
        % compute uFb2ToSb = uSbFb1_0
        tic
        uSbToFb1_0Old = uSbToFb1_0;
        for (i=1:nTypes)
            ruleIds = ruleStruct.parents==i;
            probs = ruleStruct.probs(ruleIds)';
            
            temp = sum(bsxfun(@times,uRbToFb2{i},probs),2); % sb=1
            uSbToFb1_0{i} = bsxfun(@rdivide, uRbToFb2{i}(:,1), temp + uRbToFb2{i}(:,1));
        end
        toc
        %% up pass
        
        type = 2;
        slot = 2;
        
        gbkType = gBkLookUp{type,slot};
        conversionsType = squeeze(conversions(:,type,:));
        refPointType = refPoints(:,type);
        
        r= shiftGbkIndsSimple(gbkType,conversionsType,refPointType);
    
        break;
    end

    
    %r = shiftGbkInds(gBkLookUp,size(gBkLookUp),[type,slot],conversions,size(conversions),refPoints,size(refPoints));
    %a=gBkLookUp{type,slot};
end
function conversions = getConversions(nTypes, cellParams)
    conversions = zeros(2,nTypes,nTypes);
    for n=1:nTypes
        for n2=1:nTypes
            conversions(:,n,n2) = cellParams.strides(n,1:2)./cellParams.strides(n2,1:2) ;
        end
    end
end

function [gBkLookUp,refPoints,typeInds] = getGbkLookUp(nTypes,maxSlots,ruleStruct,cellMapStruct)
    nRules = size(ruleStruct.rules,1);

    gBkLookUp = cell(nTypes,maxSlots);
    %tells where to look up inds of each type
    % typeInds(1,n2,n,k) means "tell me where the entries in gBkLookUp{n,k} 
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
                                     [chType*ones([size(locs,1),1]), locs]);
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
end