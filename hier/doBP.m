function doBP(testData,posesStruct,likePxIdxCells,cellMapStruct,cellParams,params,ruleStruct,templateStruct)
    % things stored in raster order:x,y,angleInd
    
    nTypes = numel(unique(ruleStruct.parents));
    nBricksType = zeros(nTypes,1);
    nCoordsInds = zeros(nTypes,3);
    for (n=1:nTypes)
       nBricksType(n) = size(cellParams.coords{n},1);
       nCoordsInds(n,:) = max(cellParams.coords{n},[],1); % 1-indexing
    end
    maxSlots = size(ruleStruct.children,2);

    
    [gBkLookUp,refPoints] = getGbkLookUp(nTypes,maxSlots,ruleStruct,cellMapStruct);
    conversions = getConversions(nTypes, cellParams);
    
    pGbkRbStruct = computePGbkR(gBkLookUp,ruleStruct,cellMapStruct);

    % allocate space for top-down messages
    uFb1ToSb_0 = cell(nTypes,1); % only stores uFb1ToSb=0
    uFb2ToRb = cell(nTypes,1); % stores all values
    uFb3ToGbk_1 = cell(nTypes,maxSlots);
    uGbkToFb1_0 = cell(nTypes,maxSlots); % only stores gbk->fb1= no point
    for (n=1:nTypes)
        uFb1ToSb_0{n} = 0.994 + 0.005*rand(nCoordsInds(n,:));
           
        uFb2ToRb{n} = 0.01 + 0.005*rand(nBricksType(n),sum(ruleStruct.parents== n));
        uFb2ToRb{n} = bsxfun(@rdivide, uFb2ToRb{n}, sum(uFb2ToRb{n},2));
        
        for (k=1:maxSlots)
             %who messages are intended for given by gBkLookUp.
             % 1+ is for null (no point)
            uFb3ToGbk_1{n,k} = 0.01 + 0.005*rand(nBricksType(n),1+size(gBkLookUp{n,k},2));
            uFb3ToGbk_1{n,k} = bsxfun(@rdivide, uFb3ToGbk_1{n,k}, sum(uFb3ToGbk_1{n,k},2));
            uGbkToFb1_0{n,k} = 0.9998 + 0.0001*rand(nBricksType(n),size(gBkLookUp{n,k},2)); %[#bricks, #potential children]
        end
    end
    % uSbToFb2 = uFb1ToSb
    % uRbToFb3 = uFb2ToRb

    % allocate space for bottom-up messages
    uFb1ToGbk_total_0 = cell(nTypes,maxSlots); % for a TOTAL no point. What child says to parent
    uGbkToFb3 = cell(nTypes,maxSlots);
    uRbToFb2 = cell(nTypes,1); % stores all values
    uSbToFb1_0 = cell(nTypes,1); % only stores uFb1ToSb=0
    for (n=1:nTypes)
        for (k=1:maxSlots)
            % 1+ is for null (no point)
            uGbkToFb3{n,k} = 0.01 + 0.005*rand(nBricksType(n),1+size(gBkLookUp{n,k},2));
            uGbkToFb3{n,k} = bsxfun(@rdivide, uGbkToFb3{n,k}, sum(uGbkToFb3{n,k},2));
            uFb1ToGbk_total_0{n,k} = 1- (0.00001 + 0.000001*rand(nBricksType(n),size(gBkLookUp{n,k},2)));
        end
        
        uRbToFb2{n} = 0.01 + 0.005*rand(nBricksType(n),sum(ruleStruct.parents== n));
        uRbToFb2{n} = bsxfun(@rdivide, uRbToFb2{n}, sum(uRbToFb2{n},2));
        
        uSbToFb1_0{n} = 0.01 + 0.005*rand(nBricksType(n),1);
    end
    %uFb3Rb3 = uRbToFb2;
    %uFb2ToSb = uSbFb1_0;

    while(1)
        %% down pass
        % compute uFb1ToSb_0
        tic
        display('---uFb1ToSb_0---');
        prodGbk_holder_0 = computeAllProdGbk(nTypes,maxSlots,gBkLookUp,nCoordsInds,conversions,refPoints,uGbkToFb1_0);
        for (n=1:nTypes)
            uFb1ToSb_0{n} = (1-params.probRoot)*prodGbk_holder_0{n};
        end
        toc
        % compute uFb1ToSb_0
         
        % compute uGbkToFb1_0
        display('---uGbkToFb1_0---');
        tic
        for (n=1:nTypes) % loop over parents
            for(k=1:maxSlots)
                singleLogMess_0 = log(uFb1ToGbk_total_0{n,k}/(size(uFb1ToGbk_total_0{n,k},2)-1));
                leaveOneOut_0 = bsxfun(@minus,sum(singleLogMess_0,2),singleLogMess_0);
                leaveOneOut_0 = [sum(singleLogMess_0,2),leaveOneOut_0]; % add in prob of dont point to anyone no point
                
                temp = log(uFb3ToGbk_1{n,k}) + leaveOneOut_0; % product of all others being 0, and this guy being 1. ie, this is the guy to be pointed to (including null brick)
                normProbs_1 = exp(bsxfun(@minus,temp,logsum(temp,2)));
                uGbkToFb1_0{n,k} = 1 - normProbs_1(:,2:end);
            end
        end
        toc
        
        % compute uGbkToFb1_0
        
        % compute uFb2ToRb
        display('---uFb2ToRb---');
        tic
        for (i=1:nTypes)
            ruleIds = ruleStruct.parents==i;
            probs = ruleStruct.probs(ruleIds)';
            
            temp = zeros(nBricksType(i), numel(probs));
            temp(:,1) = uFb1ToSb_0{i}(:); % stores P(rb|sb=0)m_{sb->fb2}(sb)
            temp = bsxfun(@times, (1-uFb1ToSb_0{i}(:)), probs) + temp;
            uFb2ToRb{i} = bsxfun(@rdivide,temp,sum(temp,2));
        end
        toc
        % compute uFb2ToRb
        
        % compute uFb3Gbk
        display('---uFb3Gbk---');
        tic
        logPgbkRbMuFb3 = computeLogMessPgbkRbMuFb3(nBricksType,nTypes,maxSlots,ruleStruct,cellParams,pGbkRbStruct,uGbkToFb3);
        for (n=1:nTypes)
            ags = cellParams.coords{n}(:,3);
            nAngles = numel(unique(ags));

            allSumG = sum(logPgbkRbMuFb3{n},2); %[#bricks, #rulesInvolved]
            leaveOneSlotOut = bsxfun(@minus,logPgbkRbMuFb3{n},allSumG);
            % have message for all bricks of this type, and all slots.
            % just need to include P(gbk|rb) now
            tempLogMess = logsum(bsxfun(@plus, log(uRbToFb2{n}), leaveOneSlotOut),3); %[#bricks, #rulesInvolved]
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
                        logMessageTemp(agId,:,r) = bsxfun(@plus,tempLogMess(agId,r),log(pGbkRbTemp));
                    end
                    
                end
                finalLogMess = logsum(logMessageTemp,3);
                finalLogMess(isnan(finalLogMess)) = -Inf;
                uFb3ToGbk_1{n,k} = exp(bsxfun(@minus,finalLogMess,logsum(finalLogMess,2)));
                temp =  uFb3ToGbk_1{n,k}(:);
                assert(~any(isnan(temp)));
            end
        end
        toc
        % compute uFb3Gbk
        
        %% down pass
        
        %% up pass
        % compute uFb2ToSb = uSbFb1_0
        display('---uFb2ToSb---');
        tic
        for (i=1:nTypes)
            ruleIds = ruleStruct.parents==i;
            probs = ruleStruct.probs(ruleIds)';
            
            temp = sum(bsxfun(@times,uRbToFb2{i},probs),2); % sb=1
            uSbToFb1_0{i} = bsxfun(@rdivide, uRbToFb2{i}(:,1), temp + uRbToFb2{i}(:,1));
        end
        toc
        % compute uFb2ToSb = uSbFb1_0
        
        % compute uFb3ToRb = uRbToFb2
        display('---uFb3ToRb---');
        tic
        logPgbkRbMuFb3 = computeLogMessPgbkRbMuFb3(nBricksType,nTypes,maxSlots,ruleStruct,cellParams,pGbkRbStruct,uGbkToFb3);
        for (n=1:nTypes)
            % normalize messages for each type
            temp = squeeze(sum(logPgbkRbMuFb3{n},2));
            denom = logsum(temp,2);
            uRbToFb2{n} = exp(bsxfun(@minus,temp,denom));
        end
        toc
        % compute uFb3ToRb
        
        %compute uGbkFb3
        display('---uGbkFb3---');
        tic
        uGbkToFb3 = compute_uGbkFb3(nTypes,maxSlots,uFb1ToGbk_total_0);
        toc
        
        %compute uGbkFb3
        %% up pass
        type = 2;
        slot = 2;
        
        gbkType = gBkLookUp{type,slot};
        conversionsType = squeeze(conversions(:,type,:));
        refPointType = refPoints(:,type);
        
        r= shiftGbkIndsSimple(gbkType,conversionsType,refPointType);
    end

    
    %r = shiftGbkInds(gBkLookUp,size(gBkLookUp),[type,slot],conversions,size(conversions),refPoints,size(refPoints));
    %a=gBkLookUp{type,slot};
end

function prodGbk_holder_0 = computeAllProdGbk(nTypes,maxSlots,gBkLookUp,nCoordsInds,conversions,refPoints,uGbkToFb1_0)
    prodGbk_holder_0 = cell(nTypes,1);
    for (n=1:nTypes)
        prodGbk_holder_0{n} = ones(nCoordsInds(n,:));
    end

    for (n=1:nTypes) % loop over parents
        for(k=1:maxSlots)
            gbkType = gBkLookUp{n,k};
            if(isempty(gbkType)) continue; end; % no children
            conversionsType = squeeze(conversions(:,n,:));
            refPointType = refPoints(:,n);
            
            prodGbk_holder_0 = computeProdGbk(gbkType,  conversionsType,  refPointType, nCoordsInds(n,:)', uGbkToFb1_0{n,k}, prodGbk_holder_0);
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
    %res{n} = [nBricksType(n),maxSlots,#rules involved];
    res = cell(nTypes,1);
    for (n=1:nTypes)
       res{n} = zeros(nBricksType(n),maxSlots,sum(ruleStruct.parents== n));
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
                %tempFill = tempFill + log(mUse(:,1)); %mUse(:,1) is 'point to nothing'
                tempFill(:,k) = log(mUse(:,1)); %mUse(:,1) is 'point to nothing', and there's only 1 of them
            else
                ags = cellParams.coords{parType}(:,3);
                nAngles = numel(unique(ags));
                for (ag=1:nAngles)
                    agId = ags==ag;
                    temp = log(sum(bsxfun(@times,[0,pGbkRb(:,ag)'],mUse(agId,:)),2));
                    tempFill(agId,k) = tempFill(agId,k) + temp;
                end
            end

        end
        res{parType}(:,:,thisRuleIndex) = tempFill;
    end
end


function conversions = getConversions(nTypes, cellParams)
    conversions = zeros(2,nTypes,nTypes);
    for n=1:nTypes
        for n2=1:nTypes
            conversions(:,n,n2) = cellParams.strides(n,1:2)./cellParams.strides(n2,1:2) ;
        end
    end
end

function pGbkRStruct = computePGbkR(gBkLookUp,ruleStruct,cellMapStruct)
    % in raster order!

    nTypes = numel(unique(ruleStruct.parents));
    maxSlots = size(ruleStruct.children,2);
    nRules = numel(ruleStruct.parents); 
    maxAngles = -1;
    for (n=1:nTypes)
       maxAngles = max(maxAngles,numel(cellMapStruct.angles{n})); 
    end
    
    pGbkRStruct = cell(nRules,maxSlots);
    
    for (r=1:size(ruleStruct.rules,1))
        display(['Processing rule: ', int2str(r)]);
        parType = ruleStruct.parents(r);
        for (k=1:maxSlots)
            if(ruleStruct.children(r,k) ==0) continue; end;
            gbkInds = gBkLookUp{parType,k};
            tempAll = [];
            for (ag=1:numel(cellMapStruct.angles{parType}))   
               probMapUse = cellMapStruct.probMap{r,k,ag};
               locsUse = cellMapStruct.locs{r,k,ag}';
               locsUse = [ruleStruct.children(r,k)*ones(1,size(locsUse,2)); ...
                          locsUse];
               temp = zeros(size(gbkInds,2),1);
               idGuess = 1;
               for (i=1:numel(probMapUse))
                   d = gbkInds(:,idGuess) - locsUse(:,i);
                   if (any(d > 0.001))
                       a=sum(abs(bsxfun(@minus,gbkInds',locsUse(:,i)')),2);
                       id = find(a < 0.001);
                   else
                       id = idGuess;
                   end
                   temp(id) = probMapUse(i);
                   idGuess = min(id+1,size(gbkInds,2));
               end
               tempAll = [tempAll, temp];
            end
             pGbkRStruct{r,k} = tempAll;
        end
    end
end

function [gBkLookUp,refPoints,typeInds] = getGbkLookUp(nTypes,maxSlots,ruleStruct,cellMapStruct)
    %gBkLookUp = [nTypes,maxSlots]
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