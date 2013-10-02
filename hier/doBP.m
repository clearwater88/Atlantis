    function [probOn,msgs] = doBP(cellMapStruct,cellParams,params,ruleStruct,sOn,imSize,clampToOff)
    nTypes = numel(unique(ruleStruct.parents));
    
    % cell returned in raster order for each cell
    [msgs] = getFinalMessages(cellMapStruct,cellParams,params,ruleStruct,sOn,imSize,clampToOff);
    
    probOn = cell(nTypes,1);

    for (n=1:nTypes)
        logProbs = combineLogMsgs(cat(3, ...
                                      [msgs.uFb1ToSb_0{n}(:), 1-msgs.uFb1ToSb_0{n}(:)], ...
                                      [msgs.uSbToFb1_0{n}(:), 1-msgs.uSbToFb1_0{n}(:)]));
                                  
                                  
        probOn{n} = exp(logProbs(:,2));
        if(clampToOff)
            probOn{n} = 1-clamp_msg_0(1-probOn{n},sOn,n);
        end
    end
 end

function msgs = getFinalMessages(cellMapStruct,cellParams,params,ruleStruct,sOn,imSize,clampToOff)
    % things stored in raster order:x,y,angleInd
    verbose = 0;
    
    nTypes = numel(unique(ruleStruct.parents));
    nBricksType = zeros(nTypes,1);
    nCoordsInds = cellParams.coordsSize; %[x size, y size, theta size; tensor]
    for (n=1:nTypes)
       nBricksType(n) = size(cellParams.coords{n},1);
    end
    maxSlots = size(ruleStruct.children,2);
    
    [gBkLookUp,refPoints] = getGbkLookUp(nTypes,maxSlots,ruleStruct,cellMapStruct);
    conversions = getConversions(nTypes, cellParams);
    
    pGbkRbStruct = computePGbkR(gBkLookUp,ruleStruct,cellMapStruct);
    
    % allocate space for top-down messages
    uFb1ToSb_0 = cell(nTypes,1); % only stores uFb1ToSb=0
    uFb2ToRb = cell(nTypes,1); % stores all values
    uFb3ToGbk_1 = cell(nTypes,maxSlots);
    uGbkToFb1_0 = cell(nTypes,maxSlots); % only stores gbk->fb1= no point. All mass of 0.
    for (n=1:nTypes)
        uFb1ToSb_0{n} = 0.994 + 0.001*rand(nCoordsInds(n,:));
           
        uFb2ToRb{n} = 0.01 + 0.001*rand(nBricksType(n),sum(ruleStruct.parents== n));
        uFb2ToRb{n} = bsxfun(@rdivide, uFb2ToRb{n}, sum(uFb2ToRb{n},2));
        
        for (k=1:maxSlots)
             %who messages are intended for given by gBkLookUp.
             % 1+ is for null (no point)
            uFb3ToGbk_1{n,k} = 0.01 + 0.001*rand(nBricksType(n),1+size(gBkLookUp{n,k},2));
            uFb3ToGbk_1{n,k}(:,1) = 1;
            uFb3ToGbk_1{n,k} = bsxfun(@rdivide, uFb3ToGbk_1{n,k}, sum(uFb3ToGbk_1{n,k},2));
            uGbkToFb1_0{n,k} = 1-((params.probRoot(n)) + rand(nBricksType(n),size(gBkLookUp{n,k},2))); %[#bricks, #potential children]
        end
    end
    prodGbk_0 = computeAllProdGbk(nTypes,maxSlots,gBkLookUp,nCoordsInds,conversions,refPoints,uGbkToFb1_0);
    % uRbToFb3 = uFb2ToRb

    % allocate space for bottom-up messages
    uFb1ToGbk_total_0 = cell(nTypes,maxSlots); % for a TOTAL no point. What child says to parent
    uGbkToFb3 = cell(nTypes,maxSlots);
    uRbToFb2 = cell(nTypes,1); % stores all values
    uSbToFb1_0 = cell(nTypes,1); % only stores uFb1ToSb=0
    for (n=1:nTypes)
        for (k=1:maxSlots)
            % 1+ is for null (no point)
            uGbkToFb3{n,k} = 0.01+0.001*rand(nBricksType(n),1+size(gBkLookUp{n,k},2));
            uGbkToFb3{n,k}(:,1) = 1; % likely point to nothing
            uGbkToFb3{n,k} = bsxfun(@rdivide, uGbkToFb3{n,k}, sum(uGbkToFb3{n,k},2));
            uFb1ToGbk_total_0{n,k} = 1- (0.01 +0.001*rand(nBricksType(n),size(gBkLookUp{n,k},2)));
        end
        
        uRbToFb2{n} = 0.01 + 0.001*rand(nBricksType(n),sum(ruleStruct.parents== n));
        uRbToFb2{n} = bsxfun(@rdivide, uRbToFb2{n}, sum(uRbToFb2{n},2));
        
        uSbToFb1_0{n} = 0.5 + 0.01*rand(nCoordsInds(n,:));
    end
    uSbToFb1_0 = correctFromSb_0(uSbToFb1_0,sOn);
    
    if(clampToOff==1)
        for (n=1:nTypes)
            uSbToFb1_0{n} = clamp_msg_0(uSbToFb1_0{n},sOn,n);
        end
    end
    %uFb3ToRb = uRbToFb2;
    %uFb2ToSb = uSbToFb1_0;

    for(iter=1:params.bpIter)
        %% up pass
        uGbkToFb3 = compute_uGbkFb3(nTypes,maxSlots,uFb1ToGbk_total_0);
        for (n=1:size(uGbkToFb3,1))
            for(k=1:size(uGbkToFb3,2))
                assert(~any(isnan(uGbkToFb3{n,k}(:))));
            end
        end
        
        % logPgbkRbMuFb3: [nbricks, #rules, maxSlots]
        logPgbkRbMuFb3 = computeLogMessPgbkRbMuFb3(nBricksType,nTypes,maxSlots,ruleStruct,cellParams,pGbkRbStruct,uGbkToFb3);
        for (n=1:nTypes)
            % normalize messages for each type
            temp = sum(logPgbkRbMuFb3{n},3);
            uRbToFb2{n} = exp(bsxfun(@minus,temp,logsum(temp,2)));
            assert(~any(isnan(uRbToFb2{n}(:))));
        end
        
        for (n=1:nTypes)
            ruleIds = ruleStruct.parents==n;
            probs = ruleStruct.probs(ruleIds)';
            temp1 = sum(bsxfun(@times,uRbToFb2{n},probs),2); % sb=1
            uSbToFb1_0{n} = reshape(bsxfun(@rdivide, uRbToFb2{n}(:,1), temp1 + uRbToFb2{n}(:,1)),nCoordsInds(n,:));
            assert(~any(isnan(uSbToFb1_0{n}(:))));
        end
        uSbToFb1_0 = correctFromSb_0(uSbToFb1_0,sOn);
        
        % indexed by parent;
        reverse_uSbToFb1_0 = constructReverseMap(nTypes,maxSlots,gBkLookUp,nCoordsInds,conversions,refPoints,uSbToFb1_0);
        reverseProdGbk = constructReverseMap(nTypes,maxSlots,gBkLookUp,nCoordsInds,conversions,refPoints,prodGbk_0);
        for (n=1:nTypes)
            for (k=1:maxSlots)
                
                %hack so things don't change size
                if(isempty(reverse_uSbToFb1_0{n,k}))
                    uFb1ToGbk_total_0{n,k} = uGbkToFb1_0{n,k};
                    continue;
                end;
                tempRatio = (1-params.probRoot(n))*reverseProdGbk{n,k}./uGbkToFb1_0{n,k};
                
                temp0 = reverse_uSbToFb1_0{n,k}.*tempRatio + (1-reverse_uSbToFb1_0{n,k}).*(1-tempRatio); % this is for a single value of g
                temp0 = temp0*size(gBkLookUp{n,k},2);
                temp1 = (1-reverse_uSbToFb1_0{n,k});
                uFb1ToGbk_total_0{n,k} = temp0 ./ (temp0+temp1); %for each parent, what signal the child sends
                if(~any(isnan(uFb1ToGbk_total_0{n,k}(:))));
                    temp = isnan(uFb1ToGbk_total_0{n,k}(:));
                    uFb1ToGbk_total_0{n,k}(temp) = 0.99999;
                end
                assert(~any(uFb1ToGbk_total_0{n,k}(:)< -0.0001));
            end
        end
        %% up pass
        
        %% down pass
        
        for (n=1:nTypes)
            uFb1ToSb_0{n} = (1-params.probRoot(n))*prodGbk_0{n};
            assert(~any(isnan(uFb1ToSb_0{n}(:))));
        end
        
        if(clampToOff==1)
            for (n=1:nTypes)
                uFb1ToSb_0{n} = clamp_msg_0(uFb1ToSb_0{n},sOn,n);
            end
        end
        
        uSbToFb2_0 = uFb1ToSb_0;
        uSbToFb2_0 = correctFromSb_0(uSbToFb2_0,sOn);
        
        for (n=1:nTypes)
            ruleIds = ruleStruct.parents==n;
            probs = ruleStruct.probs(ruleIds)';
            
            temp = zeros(nBricksType(n), numel(probs));
            temp(:,1) = uSbToFb2_0{n}(:); % stores P(rb|sb=0)m_{sb->fb2}(sb)
            temp = bsxfun(@times, (1-uFb1ToSb_0{n}(:)), probs) + temp;
            uFb2ToRb{n} = bsxfun(@rdivide,temp,sum(temp,2));
            assert(~any(isnan(uFb2ToRb{n}(:))));
        end
        
        % logPgbkRbMuFb3: [nbricks, #rules, maxSlots]
        logPgbkRbMuFb3 = computeLogMessPgbkRbMuFb3(nBricksType,nTypes,maxSlots,ruleStruct,cellParams,pGbkRbStruct,uGbkToFb3);
        for (n=1:nTypes)
            ags = cellParams.coords{n}(:,3);
            nAngles = numel(unique(ags));
            
            allSumG = sum(logPgbkRbMuFb3{n},3); %[#bricks, #rulesInvolved]
            leaveOneSlotOut = bsxfun(@minus,allSumG,logPgbkRbMuFb3{n});
            % have message for all bricks of this type, and all slots.
            % just need to include P(gbk|rb) now
            tempLogMess = bsxfun(@plus, log(uFb2ToRb{n}), leaveOneSlotOut); %[#bricks,#rulesInvolved,maxSlots]
            ruleIds = find(ruleStruct.parents==n);
            for(k=1:maxSlots) % sweep over angles, so we can index into pGbkRb
                logMessageTemp = zeros(nBricksType(n),1+size(gBkLookUp{n,k},2),numel(ruleIds));
                for (r=1:numel(ruleIds))
                    
                    pGbkRb = pGbkRbStruct{ruleIds(r),k};
                    if(isempty(pGbkRb))
                        logMessageTemp(:,2:end,r) = -Inf;
                        continue;
                    end;
                    for (ag=1:nAngles)
                        agId = ags==ag;
                        pGbkRbTemp = [0,pGbkRb(:,ag)'];
                        logMessageTemp(agId,:,r) = bsxfun(@plus,tempLogMess(agId,r,k),log(pGbkRbTemp));
                    end
                    
                end
                finalLogMess = logsum(logMessageTemp,3);
                finalLogMess(isnan(finalLogMess)) = -Inf;
                uFb3ToGbk_1{n,k} = exp(bsxfun(@minus,finalLogMess,logsum(finalLogMess,2)));
                assert(~any(isnan(uFb3ToGbk_1{n,k}(:))));
            end
        end
        
        for (n=1:nTypes) % loop over parents
            for(k=1:maxSlots)
                %singleLogMess_0 = log(uFb1ToGbk_total_0{n,k}/(size(uFb1ToGbk_total_0{n,k},2)-1)); % WRONG WAY TO NORMALIZE
                singleLogMess_0 = log(uFb1ToGbk_total_0{n,k}/(size(uFb1ToGbk_total_0{n,k},2)-1));
                
                allOtherProd0 = bsxfun(@minus,sum(singleLogMess_0,2),singleLogMess_0); %log(prod_{b,k} != this brick and slot)
                
                logProbs_1 = [sum(singleLogMess_0,2),allOtherProd0 + log(1-uFb1ToGbk_total_0{n,k})];
                logProbs_1 = logProbs_1 + log(uFb3ToGbk_1{n,k});
                normProbs_1 = exp(bsxfun(@minus,logProbs_1,logsum(logProbs_1,2)));
                uGbkToFb1_0{n,k} = 1 - normProbs_1(:,2:end);
                
                temp =  uGbkToFb1_0{n,k};
                temp(temp<0.000001)=0.000001;
                temp(isnan(temp)) = 0.000001;
                uGbkToFb1_0{n,k} = temp;
                
                assert(~any(isnan(uGbkToFb1_0{n,k}(:))));
            end
        end
        prodGbk_0 = computeAllProdGbk(nTypes,maxSlots,gBkLookUp,nCoordsInds,conversions,refPoints,uGbkToFb1_0);
        
        %% down pass
        
        if(verbose)
            probOn = cell(nTypes,1);
            figure(1000);
            for (n=1:nTypes)
                probs = combineMsgs(cat(3,...
                    [uFb1ToSb_0{n}(:), 1-uFb1ToSb_0{n}(:)], ...
                    [uSbToFb1_0{n}(:), 1-uSbToFb1_0{n}(:)]));
                probOn{n} = probs(:,2);
            end
            viewHeatMap(sOn,probOn,cellParams,imSize);
        end
    end
    msgs.uFb1ToSb_0 = uFb1ToSb_0;
    msgs.uFb2ToRb = uFb2ToRb;
    msgs.uFb3ToGbk_1 = uFb3ToGbk_1;
    msgs.uGbkToFb1_0 = uGbkToFb1_0;
    msgs.uGbkToFb3 = uGbkToFb3;
    msgs.uRbToFb2 = uRbToFb2;
    msgs.uSbToFb1_0 = uSbToFb1_0;
    msgs.uSbToFb2_0 = uSbToFb2_0;
    
end

function res = clamp_msg_0(msg_0,sOn,type)

    sz = size(msg_0);
    res = ones(prod(sz),1);

    ids = sOn(1,:) == type;
    cellIdx = sOn(2,ids);
    res(cellIdx) = msg_0(cellIdx);
    
    res = reshape(res,sz);
end

function fromSb = correctFromSb_0(fromSb,sOn)
    %sOn(:,i) = [type,idx,probOn]

    for (i=1:size(sOn,2))
        type = sOn(1,i);
        idx = sOn(2,i);
        probOn = sOn(3,i);
        temp = fromSb{type};
        temp(idx) = 1-probOn;
        fromSb{type} = temp;
    end
end

function res = constructReverseMap(nTypes,maxSlots,gBkLookUp,nCoordsInds,conversions,refPoints,mp)

	res = cell(nTypes,maxSlots);
    for (n=1:nTypes) % loop over parents
        for(k=1:maxSlots)
            gbkType = gBkLookUp{n,k};
            if(isempty(gbkType)) continue; end; % no children
            conversionsType = squeeze(conversions(:,n,:));
            refPointType = refPoints(:,n);
            
            res{n,k} = reverseMap(gbkType, conversionsType,  refPointType, nCoordsInds(n,:)', mp, ones(prod(nCoordsInds(n,:)), size(gbkType,2)));
        end
    end
end

function prodGbk_0 = computeAllProdGbk(nTypes,maxSlots,gBkLookUp,nCoordsInds,conversions,refPoints,uGbkToFb1_0)
    % prodGbk_holder_0{n}(coord): product of Gbk's of this brick's parents

    prodGbk_0 = cell(nTypes,1);
    for (n=1:nTypes)
        prodGbk_0{n} = ones(nCoordsInds(n,:));
    end

    for (n=1:nTypes) % loop over parents
        for(k=1:maxSlots)
            gbkType = gBkLookUp{n,k};
            if(isempty(gbkType)) continue; end; % no children
            conversionsType = squeeze(conversions(:,n,:));
            refPointType = refPoints(:,n);
            
            prodGbk_0 = computeProdGbk(gbkType,  conversionsType,  refPointType, nCoordsInds(n,:)', uGbkToFb1_0{n,k}, prodGbk_0);
        end
    end
end

function res = compute_uGbkFb3(nTypes,maxSlots,uFb1ToGbk_total_0)
    %uFb1Gbk_0: cell(#types,maxSlots)
    %uFb1Gbk_0{n,k}: [#types,#potential children]);
    res = cell(nTypes,maxSlots);
    
    for (n=1:nTypes)
        for(k=1:maxSlots)
            logMUse_0 = log(uFb1ToGbk_total_0{n,k});
            allLogSum = sum(logMUse_0,2);
            temp = bsxfun(@plus, log(1-uFb1ToGbk_total_0{n,k}) - logMUse_0,allLogSum);
            temp = [allLogSum,temp]; % first slot is point to no one
            denom = logsum(temp,2);
            res{n,k} = exp(bsxfun(@minus,temp,denom));
        end
    end  
end

function res = computeLogMessPgbkRbMuFb3(nBricksType,nTypes,maxSlots,ruleStruct,cellParams,pGbkRbStruct,uGbkFb3)
    %res{n} = [nBricksType(n),#rules,maxSlots];
    res = cell(nTypes,1);
    for (n=1:nTypes)
       res{n} = zeros(nBricksType(n),sum(ruleStruct.parents== n),maxSlots);
    end
    
    for (r=1:numel(ruleStruct.parents))
        parType = ruleStruct.parents(r);
        rules = find(ruleStruct.parents==parType);
        thisRuleIndex = rules==r;
        % container for \prod_k \sum_{g_k} P(gbk|rb) m(gbk->fb3)
        tempFill=zeros(size(cellParams.coords{parType},1),maxSlots);
        for (k=1:maxSlots)
            pGbkRb = pGbkRbStruct{r,k};
            mUse = uGbkFb3{parType,k};
            % that means all mass from pGbkRb on off
            if(isempty(pGbkRb))
                tempFill(:,k) = log(mUse(:,1)); %mUse(:,1) is 'point to nothing', and there's only 1 of them
            else
                ags = cellParams.coords{parType}(:,3);
                nAngles = numel(unique(ags));
                for (ag=1:nAngles)
                    agId = ags==ag;
                    temp = log(sum(bsxfun(@times,[0,pGbkRb(:,ag)'],mUse(agId,:)),2));
                    tempFill(agId,k) = temp;
                end
            end
        end
        res{parType}(:,thisRuleIndex,:) = tempFill;
    end
end

