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
    log_uGbkToFb1_0 = cell(nTypes,maxSlots); % only stores gbk->fb1= no point. All mass of 0.
    for (n=1:nTypes)
        uFb1ToSb_0{n} = 0.999+0.0001*rand(nCoordsInds(n,:));
           
        probs = ruleStruct.probs(ruleStruct.parents==n)';
        uFb2ToRb{n} = bsxfun(@plus,probs,0.01*rand(nBricksType(n),sum(ruleStruct.parents== n)));
        
        %uFb2ToRb{n} = 0.01 + 0.1*rand(nBricksType(n),sum(ruleStruct.parents== n));
        uFb2ToRb{n} = bsxfun(@rdivide, uFb2ToRb{n}, sum(uFb2ToRb{n},2));
        
        for (k=1:maxSlots)
             %who messages are intended for given by gBkLookUp.
             % 1+ is for null (no point)
            uFb3ToGbk_1{n,k} = 1 + 0.1*rand(nBricksType(n),1+size(gBkLookUp{n,k},2));
            uFb3ToGbk_1{n,k}(:,1) = 0.01;
            uFb3ToGbk_1{n,k} = bsxfun(@rdivide, uFb3ToGbk_1{n,k}, sum(uFb3ToGbk_1{n,k},2));
            log_uGbkToFb1_0{n,k} = log(1- (0.00001 + 0.0*rand(nBricksType(n),size(gBkLookUp{n,k},2)))); %[#bricks, #potential children]
        end
    end
    logProdGbk_0 = computeAllLogProdGbk(nTypes,maxSlots,gBkLookUp,nCoordsInds,conversions,refPoints,log_uGbkToFb1_0);
    
    % uRbToFb3 = uFb2ToRb

    % allocate space for bottom-up messages
    log_uFb1ToGbk_total_0 = cell(nTypes,maxSlots); % for a TOTAL no point. What child says to parent
    uRbToFb2 = cell(nTypes,1); % stores all values
    uSbToFb1_0 = cell(nTypes,1); % only stores uFb1ToSb=0
    for (n=1:nTypes)
        for (k=1:maxSlots)
            log_uFb1ToGbk_total_0{n,k} = log((0.1 + 0.1*rand(nBricksType(n),size(gBkLookUp{n,k},2))));
        end
        
        probs = ruleStruct.probs(ruleStruct.parents==n)';
        uRbToFb2{n} = bsxfun(@plus,probs,0.01*rand(nBricksType(n),sum(ruleStruct.parents== n)));
        uRbToFb2{n} = bsxfun(@rdivide, uRbToFb2{n}, sum(uRbToFb2{n},2));
        
        uSbToFb1_0{n} = 0.994 + 0.001*rand(nCoordsInds(n,:));
    end
    uSbToFb1_0 = correctFromSb_0(uSbToFb1_0,sOn);
    log_uGbkToFb3 = compute_log_uGbkFb3(nTypes,maxSlots,log_uFb1ToGbk_total_0);
    
    if(clampToOff==1)
        for (n=1:nTypes)
            uSbToFb1_0{n} = clamp_msg_0(uSbToFb1_0{n},sOn,n);
        end
    end
    %uFb3ToRb = uRbToFb2;
    %uFb2ToSb = uSbToFb1_0;

    %nChildren = countChildren(gBkLookUp,nCoordsInds,conversions,refPoints);
    
    for(iter=1:params.bpIter)
        
        timeStart=tic;
        
        %% up pass
        if(verbose)
           display(['Computing: log_uGbkToFb3']);
           tic
        end
        log_uGbkToFb3 = compute_log_uGbkFb3(nTypes,maxSlots,log_uFb1ToGbk_total_0);
        if(verbose)
            toc;
        end
        
        if(verbose)
           display(['Computing: logPgbkRbMuFb3 and uRbToFb2']);
           tic
        end
        % logPgbkRbMuFb3: [nbricks, #rules, maxSlots]
        logPgbkRbMuFb3 = computeLogMessPgbkRbMuFb3(nBricksType,nTypes,maxSlots,ruleStruct,cellParams,pGbkRbStruct,log_uGbkToFb3);
        for (n=1:nTypes)
            % normalize messages for each type
            temp = sum(logPgbkRbMuFb3{n},3);
            uRbToFb2{n} = exp(bsxfun(@minus,temp,logsum(temp,2)));
        end
        if(verbose)
            toc;
        end
        
        if(verbose)
           display(['Computing: uSbToFb1_0']);
           tic
        end
        for (n=1:nTypes)
            ruleIds = ruleStruct.parents==n;
            probs = ruleStruct.probs(ruleIds)';
            temp1 = sum(bsxfun(@times,uRbToFb2{n},probs),2); % sb=1
            uSbToFb1_0{n} = reshape(bsxfun(@rdivide, uRbToFb2{n}(:,1), temp1 + uRbToFb2{n}(:,1)),nCoordsInds(n,:));
        end
        uSbToFb1_0 = correctFromSb_0(uSbToFb1_0,sOn);
        if(verbose)
            toc;
        end
        
        % indexed by parent;
        if(verbose)
           display(['Computing: reverse_uSbToFb1_0 and reverseProdGbk']);
           tic
        end
        
        reverse_uSbToFb1_0 = constructReverseMap(nTypes,maxSlots,gBkLookUp,nCoordsInds,conversions,refPoints,uSbToFb1_0,1);
        logReverseProdGbk = constructReverseMap(nTypes,maxSlots,gBkLookUp,nCoordsInds,conversions,refPoints,logProdGbk_0,0);
        if(verbose)
            toc;
        end
        
        if(verbose)
           display(['Computing: log_uFb1ToGbk_total_0']);
           tic
        end
        for (n=1:nTypes)
            for (k=1:maxSlots)
                
                %hack so things don't change size
                if(isempty(reverse_uSbToFb1_0{n,k}))
                    log_uFb1ToGbk_total_0{n,k} = log_uGbkToFb1_0{n,k};
                    continue;
                end;
                %tempRatio = (1-params.probRoot(n))*reverseProdGbk{n,k}./uGbkToFb1_0{n,k};
                tempRatio = (1-params.probRoot(n))*exp(logReverseProdGbk{n,k}-log_uGbkToFb1_0{n,k});
                
                temp0 = reverse_uSbToFb1_0{n,k}.*tempRatio + (1-reverse_uSbToFb1_0{n,k}).*(1-tempRatio); % this is for a single value of g
                %temp0 = temp0*(size(gBkLookUp{n,k},2)-1); % approximate number of other chidlren the parent has
                temp1 = (1-reverse_uSbToFb1_0{n,k});
                log_uFb1ToGbk_total_0{n,k} = log(temp0) - log(temp0+temp1); %for each parent, what signal the child sends
            end
        end
        if(verbose)
            toc;
        end
        %% up pass
        
        %% down pass
        if(verbose)
           display(['Computing: uFb1ToSb_0']);
           tic
        end
        for (n=1:nTypes)
            %uFb1ToSb_0{n} = (1-params.probRoot(n))*prodGbk_0{n};
            uFb1ToSb_0{n} = (1-params.probRoot(n))*exp(logProdGbk_0{n});
            assert(~any(isnan(uFb1ToSb_0{n}(:))));
        end
        if(clampToOff==1)
            for (n=1:nTypes)
                uFb1ToSb_0{n} = clamp_msg_0(uFb1ToSb_0{n},sOn,n);
            end
        end
        if(verbose)
            toc;
        end
        
        uSbToFb2_0 = uFb1ToSb_0;
        uSbToFb2_0 = correctFromSb_0(uSbToFb2_0,sOn);
        
        if(verbose)
           display(['Computing: uFb2ToRb']);
           tic
        end
        for (n=1:nTypes)
            ruleIds = ruleStruct.parents==n;
            probs = ruleStruct.probs(ruleIds)';
            
            temp = zeros(nBricksType(n), numel(probs));
            temp(:,1) = uSbToFb2_0{n}(:); % stores P(rb|sb=0)m_{sb->fb2}(sb)
            temp = bsxfun(@times, (1-uFb1ToSb_0{n}(:)), probs) + temp;
            uFb2ToRb{n} = bsxfun(@rdivide,temp,sum(temp,2));
        end
        if(verbose)
            toc;
        end

        if(verbose)
           display(['Computing: uFb3ToGbk_1']);
           tic
        end
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
                        logMessageTemp(:,2:end,r) = -10^10;
                        continue;
                    end;
                    for (ag=1:nAngles)
                        agId = ags==ag;
                        logPGbkRbTemp = log([10^-10,pGbkRb(:,ag)']);
                        logMessageTemp(agId,:,r) = bsxfun(@plus,tempLogMess(agId,r,k),logPGbkRbTemp);
                        
                        temp = logMessageTemp(agId,:,r);
                        temp(isinf(temp)) = -10^10;
                        logMessageTemp(agId,:,r) = temp;
                    end
                    
                end
                finalLogMess = logsum(logMessageTemp,3);
                uFb3ToGbk_1{n,k} = exp(bsxfun(@minus,finalLogMess,logsum(finalLogMess,2)));
            end
        end
        if(verbose)
            toc;
        end
        
        if(verbose)
           display(['Computing: log_uGbkToFb1_0']);
           tic
        end
        for (n=1:nTypes) % loop over parents
            for(k=1:maxSlots)
                %singleLogMess_0 = uFb1ToGbk_total_0{n,k}/(size(uFb1ToGbk_total_0{n,k},2)-1)); % WRONG WAY TO NORMALIZE
                singleLogMess_0 = log_uFb1ToGbk_total_0{n,k}-log((size(log_uFb1ToGbk_total_0{n,k},2)-1));
                
                allOtherProd0 = bsxfun(@minus,sum(singleLogMess_0,2),singleLogMess_0); %log(prod_{b,k} != this brick and slot)
                
                logProbs_1 = [sum(singleLogMess_0,2),allOtherProd0 + log(1-exp(log_uFb1ToGbk_total_0{n,k}))];
                logProbs_1 = logProbs_1 + log(uFb3ToGbk_1{n,k});
                normProbs_1 = exp(bsxfun(@minus,logProbs_1,logsum(logProbs_1,2)));
                log_uGbkToFb1_0{n,k} = log(1 - normProbs_1(:,2:end));

            end
        end
        if(verbose)
            toc;
        end
        
        if(verbose)
           display(['Computing: logProdGbk_0']);
           tic
        end
        logProdGbk_0 = computeAllLogProdGbk(nTypes,maxSlots,gBkLookUp,nCoordsInds,conversions,refPoints,log_uGbkToFb1_0);
        if(verbose)
            toc;
        end
        
        %% down pass
        
        if(verbose)
            probOn = cell(nTypes,1);
            
            for (n=1:nTypes)
                logProbs = combineLogMsgs(cat(3,...
                    [uFb1ToSb_0{n}(:), 1-uFb1ToSb_0{n}(:)], ...
                    [uSbToFb1_0{n}(:), 1-uSbToFb1_0{n}(:)]));
                probOn{n} = exp(logProbs(:,2));
                assert(~any(isnan(probOn{n})));
            end
            %figure(1000);
            %viewHeatMap(sOn,probOn,cellParams,imSize);
        end
        display(['***Time for iter: ', num2str(toc(timeStart)), '***']);
    end
    
    msgs.uFb1ToSb_0 = uFb1ToSb_0;
    msgs.uFb2ToRb = uFb2ToRb;
    msgs.uFb3ToGbk_1 = uFb3ToGbk_1;
    msgs.log_uGbkToFb1_0 = log_uGbkToFb1_0;
    msgs.log_uGbkToFb3 = log_uGbkToFb3;
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

function res = constructReverseMap(nTypes,maxSlots,gBkLookUp,nCoordsInds,conversions,refPoints,mp,defaultVal)

	res = cell(nTypes,maxSlots);
    for (n=1:nTypes) % loop over parents
        for(k=1:maxSlots)
            gbkType = gBkLookUp{n,k};
            if(isempty(gbkType)) continue; end; % no children
            conversionsType = squeeze(conversions(:,n,:));
            refPointType = refPoints(:,n);
            
            res{n,k} = reverseMap(gbkType, conversionsType,  refPointType, nCoordsInds(n,:)', mp, defaultVal*ones(prod(nCoordsInds(n,:)), size(gbkType,2)));
        end
    end
end

function logProdGbk_0 = computeAllLogProdGbk(nTypes,maxSlots,gBkLookUp,nCoordsInds,conversions,refPoints,log_uGbkToFb1_0)
    % logProdGbk_0{n}(coord): log sum of Gbk's of this brick's parents

    logProdGbk_0 = cell(nTypes,1);
    for (n=1:nTypes)
        logProdGbk_0{n} = zeros(nCoordsInds(n,:));
    end

    logProdGbk2_0 = cell(nTypes,1);
    for (n=1:nTypes)
        logProdGbk2_0{n} = zeros(nCoordsInds(n,:));
    end
    
    for (n=1:nTypes) % loop over parents
        for(k=1:maxSlots)
            gbkType = gBkLookUp{n,k};
            if(isempty(gbkType)) continue; end; % no children
            conversionsType = squeeze(conversions(:,n,:));
            refPointType = refPoints(:,n);
            
            logProdGbk_0 = computeLogProdGbk(gbkType, conversionsType,  refPointType, nCoordsInds(n,:)', log_uGbkToFb1_0{n,k}, logProdGbk_0);
        end
    end
    
end

function res = compute_log_uGbkFb3(nTypes,maxSlots,log_uFb1ToGbk_total_0)
    %uFb1Gbk_0: cell(#types,maxSlots)
    %uFb1Gbk_0{n,k}: [#types,#potential children]);
    res = cell(nTypes,maxSlots);
    
    for (n=1:nTypes)
        for(k=1:maxSlots)
            logMUse_0 = log_uFb1ToGbk_total_0{n,k};
            allLogSum = sum(logMUse_0,2);
            temp = bsxfun(@plus, log(1-exp(log_uFb1ToGbk_total_0{n,k})) - logMUse_0,allLogSum);
            temp = [allLogSum,temp]; % first slot is point to no one
            denom = logsum(temp,2);
            res{n,k} = bsxfun(@minus,temp,denom);
        end
    end  
end

function res = computeLogMessPgbkRbMuFb3(nBricksType,nTypes,maxSlots,ruleStruct,cellParams,pGbkRbStruct,log_uGbkToFb3)
    %res{n} = [nBricksType(n),#rules,maxSlots];
    res = cell(nTypes,1);
    for (n=1:nTypes)
       res{n} = zeros(nBricksType(n),sum(ruleStruct.parents== n),maxSlots);
    end
    
    for (r=1:numel(ruleStruct.parents))
        parType = ruleStruct.parents(r);
        rules = find(ruleStruct.parents==parType);
        thisRuleIndex = rules==r;
        % container for \sum_{g_k} P(gbk|rb) m(gbk->fb3)
        tempFill=zeros(size(cellParams.coords{parType},1),maxSlots);
        for (k=1:maxSlots)
            pGbkRb = pGbkRbStruct{r,k};
            mUse = log_uGbkToFb3{parType,k};
            % that means all mass from pGbkRb on off
            if(isempty(pGbkRb))
                tempFill(:,k) = mUse(:,1); %mUse(:,1) is 'point to nothing', and there's only 1 of them
                %tempFill(:,k) = 0;
            else
                ags = cellParams.coords{parType}(:,3);
                nAngles = numel(unique(ags));
                for (ag=1:nAngles)
                    agId = ags==ag;
                    %temp = log(sum(bsxfun(@times,[0,pGbkRb(:,ag)'],mUse(agId,:)),2));
                    temp=(logsum(bsxfun(@plus,log([10^-10,pGbkRb(:,ag)']),mUse(agId,:)),2));
                    %temp=(logsum(bsxfun(@plus,log([10^-10,pGbkRb(:,ag)']),0),2));
                    tempFill(agId,k) = temp;
                end
            end
        end
        res{parType}(:,thisRuleIndex,:) = tempFill;
    end
end

