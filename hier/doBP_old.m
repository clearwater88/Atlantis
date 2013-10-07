function probOn = doBP_old(cellMapStruct,cellParams,params,ruleStruct,sOn)

% cell returned in raster order for each cell
    probOn = getProbBricksOn(cellMapStruct,cellParams,params,ruleStruct,sOn);
end

function probOn = getProbBricksOn(cellMapStruct,cellParams,params,ruleStruct,sOn)
% things stored in raster order:x,y,angleInd
    
    nTypes = numel(unique(ruleStruct.parents));
    nBricksType = zeros(nTypes,1);
    nCoordsInds = cellParams.coordsSize;
    for (n=1:nTypes)
       nBricksType(n) = size(cellParams.coords{n},1);
    end
    maxSlots = size(ruleStruct.children,2);

    probOn = cell(nTypes,1);
    
    [gBkLookUp,refPoints] = getGbkLookUp(nTypes,maxSlots,ruleStruct,cellMapStruct);
    conversions = getConversions(nTypes, cellParams);
    
    pGbkRbStruct = computePGbkR(gBkLookUp,ruleStruct,cellMapStruct);

% for (r=1:numel(pGbkRbStruct))
% pGbkRbStruct{r} = ones(size(pGbkRbStruct{r}))/size(pGbkRbStruct{r},1);
% end
    
    % allocate space for top-down messages
    uFb1ToSb_0 = cell(nTypes,1); % only stores uFb1ToSb=0
    uFb2ToRb = cell(nTypes,1); % stores all values
    uFb3ToGbk_1 = cell(nTypes,maxSlots);
    uGbkToFb1_0 = cell(nTypes,maxSlots); % only stores gbk->fb1= no point. All mass of 0.
    for (n=1:nTypes)
        uFb1ToSb_0{n} = 0.99994 + 0.000001*rand(nCoordsInds(n,:));
           
        uFb2ToRb{n} = 0.01 + 0.001*rand(nBricksType(n),sum(ruleStruct.parents== n));
        uFb2ToRb{n} = bsxfun(@rdivide, uFb2ToRb{n}, sum(uFb2ToRb{n},2));
        
        for (k=1:maxSlots)
             %who messages are intended for given by gBkLookUp.
             % 1+ is for null (no point)
            uFb3ToGbk_1{n,k} = 0.001 + 0.0001*rand(nBricksType(n),1+size(gBkLookUp{n,k},2));
            uFb3ToGbk_1{n,k}(:,1) = 10000;
            uFb3ToGbk_1{n,k} = bsxfun(@rdivide, uFb3ToGbk_1{n,k}, sum(uFb3ToGbk_1{n,k},2));
            uGbkToFb1_0{n,k} = 1-((0.004*params.probRoot(n)) + (0.004*params.probRoot(n))*0.1*rand(nBricksType(n),size(gBkLookUp{n,k},2))); %[#bricks, #potential children]
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
            uGbkToFb3{n,k} = 0.001+0.0001*rand(nBricksType(n),1+size(gBkLookUp{n,k},2));
            uGbkToFb3{n,k}(:,1) = 10000; % likely point to nothing
            uGbkToFb3{n,k} = bsxfun(@rdivide, uGbkToFb3{n,k}, sum(uGbkToFb3{n,k},2));
            uFb1ToGbk_total_0{n,k} = 1- (0.0001 +0.00001*rand(nBricksType(n),size(gBkLookUp{n,k},2)));
        end
        
        uRbToFb2{n} = 0.01 + 0.0001*rand(nBricksType(n),sum(ruleStruct.parents== n));
        uRbToFb2{n} = bsxfun(@rdivide, uRbToFb2{n}, sum(uRbToFb2{n},2));
        
        uSbToFb1_0{n} = 0.5 + 0.001*rand(nCoordsInds(n,:));
    end
    uSbToFb1_0 = correctFromSb_0(uSbToFb1_0,sOn);
    %uFb3ToRb = uRbToFb2;
    %uFb2ToSb = uSbToFb1_0;

    for(iter=1:params.bpIter)
        %% up pass
         
        %compute uGbkToFb3
        %if(mod(iter-1,8) == 0)
            display('---uGbkFb3---');
            tic
            uGbkToFb3_old{iter} = uGbkToFb3;
            uGbkToFb3 = compute_uGbkFb3(nTypes,maxSlots,uFb1ToGbk_total_0);
            for (n=1:size(uGbkToFb3,1))
                for(k=1:size(uGbkToFb3,2))
                    assert(~any(isnan(uGbkToFb3{n,k}(:))));
                end
            end
            toc
        %end
        %compute uGbkToFb3
         
        %compute uFb3ToRb = uRbToFb2
        %if(mod(iter-1,8) == 1)
            display('---uFb3ToRb---');
            tic
            uRbToFb2_old{iter} = uRbToFb2;
            % logPgbkRbMuFb3: [nbricks, #rules, maxSlots]
            logPgbkRbMuFb3 = computeLogMessPgbkRbMuFb3(nBricksType,nTypes,maxSlots,ruleStruct,cellParams,pGbkRbStruct,uGbkToFb3);
            for (n=1:nTypes)
                % normalize messages for each type
                temp = sum(logPgbkRbMuFb3{n},3);
                uRbToFb2{n} = exp(bsxfun(@minus,temp,logsum(temp,2)));
                assert(~any(isnan(uRbToFb2{n}(:))));
            end
            toc
        %end
        %compute uFb3ToRb = uRbToFb2
         
        %compute uSbFb1_0 = uFb2ToSb
        %if(mod(iter-1,8) == 2)
            display('---uFb2ToSb---');
            tic
            uSbToFb1_0_old{iter} = uSbToFb1_0;
            for (n=1:nTypes)
                ruleIds = ruleStruct.parents==n;
                probs = ruleStruct.probs(ruleIds)';
                temp1 = sum(bsxfun(@times,uRbToFb2{n},probs),2); % sb=1
                uSbToFb1_0{n} = reshape(bsxfun(@rdivide, uRbToFb2{n}(:,1), temp1 + uRbToFb2{n}(:,1)),nCoordsInds(n,:));
                assert(~any(isnan(uSbToFb1_0{n}(:))));
            end
            uSbToFb1_0 = correctFromSb_0(uSbToFb1_0,sOn);
            toc
        %end
        % compute uSbFb1_0 = uFb2ToSb
        
        % compute uFb1ToGbk_total_0
        %if(mod(iter-1,8) == 3)
            tic
            uFb1ToGbk_total_0_old{iter} = uFb1ToGbk_total_0;
            display('---uFb1ToGbk_total_0---');
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
                    assert(~any(isnan(uFb1ToGbk_total_0{n,k}(:))));
                    assert(~any(uFb1ToGbk_total_0{n,k}(:)< -0.0001));
                end
            end
            toc
        %end
        %compute uFb1ToGbk_total_0

        %% up pass
        
        %% down pass
        
        % compute uFb1ToSb_0 = uSbToFb2_0
        %if(mod(iter-1,8) == 4)
            tic
            display('---uFb1ToSb_0---');
            uFb1ToSb_0_old{iter} = uFb1ToSb_0;
            for (n=1:nTypes)
                uFb1ToSb_0{n} = (1-params.probRoot(n))*prodGbk_0{n};
                assert(~any(isnan(uFb1ToSb_0{n}(:))));
            end

            uSbToFb2_0 = uFb1ToSb_0;
            uSbToFb2_0 = correctFromSb_0(uSbToFb2_0,sOn);
            toc;
        %end
        % compute uFb1ToSb_0 = uSbToFb2_0
        
        % compute uFb2ToRb = uRbToFb3
        %if(mod(iter-1,8) == 5)
            display('---uFb2ToRb---');
            tic
            for (n=1:nTypes)
                ruleIds = ruleStruct.parents==n;
                probs = ruleStruct.probs(ruleIds)';

                temp = zeros(nBricksType(n), numel(probs));
                temp(:,1) = uSbToFb2_0{n}(:); % stores P(rb|sb=0)m_{sb->fb2}(sb)
                temp = bsxfun(@times, (1-uFb1ToSb_0{n}(:)), probs) + temp;
                uFb2ToRb{n} = bsxfun(@rdivide,temp,sum(temp,2));
                assert(~any(isnan(uFb2ToRb{n}(:))));
            end
            toc
        %end
        % compute uFb2ToRb = uRbToFb3
        
         % compute uFb3ToGbk_1
         %if(mod(iter-1,8) == 6)
             display('---uFb3Gbk---');
             uFb3ToGbk_1_old{iter} = uFb3ToGbk_1;
             tic
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
                     finalLogMess(isnan(finalLogMess)) = -10^10;
                     uFb3ToGbk_1{n,k} = exp(bsxfun(@minus,finalLogMess,logsum(finalLogMess,2)));
                     assert(~any(isnan(uFb3ToGbk_1{n,k}(:))));
                 end
             end
             toc
         %end
        % compute uFb3ToGbk_1
        
        % compute uGbkToFb1_0
        %if(mod(iter-1,8) == 7)
            display('---uGbkToFb1_0---');
            tic
            uGbkToFb1_0_old{iter} = uGbkToFb1_0;
            for (n=1:nTypes) % loop over parents
                for(k=1:maxSlots)
                    %singleLogMess_0 = log(uFb1ToGbk_total_0{n,k}/(size(uFb1ToGbk_total_0{n,k},2)-1)); % WRONG WAY TO NORMALIZE
                    singleLogMess_0 = log(uFb1ToGbk_total_0{n,k}/(size(uFb1ToGbk_total_0{n,k},2)-1));

                    allOtherProd0 = bsxfun(@minus,sum(singleLogMess_0,2),singleLogMess_0); %log(prod_{b,k} != this brick and slot)

                    logProbs_1 = [sum(singleLogMess_0,2),allOtherProd0 + log(1-uFb1ToGbk_total_0{n,k})];
                    logProbs_1 = logProbs_1 + log(uFb3ToGbk_1{n,k});
                    normProbs_1 = exp(bsxfun(@minus,logProbs_1,logsum(logProbs_1,2)));
                    uGbkToFb1_0{n,k} = 1 - normProbs_1(:,2:end);
                    assert(~any(isnan(uGbkToFb1_0{n,k}(:))));
                end
            end
            prodGbk_0_oldFb1{iter} = prodGbk_0;
            prodGbk_0 = computeAllProdGbk(nTypes,maxSlots,gBkLookUp,nCoordsInds,conversions,refPoints,uGbkToFb1_0);
            
            toc
        %end
        % compute uGbkToFb1_0

        %% down pass
        
        %% compute prob of on for each brick
        for (n=1:nTypes)
            Fb1Sb0 = uFb1ToSb_0{n};
            Fb2Sb0 = uSbToFb1_0{n}; % equivalent messages
            
            prob0 = Fb1Sb0.*Fb2Sb0;
            prob1 = (1-Fb1Sb0).*(1-Fb2Sb0);
            probOn{n} = prob1./(prob0+prob1);
            probOn{n} = probOn{n}(:);
% figure(100);
% title(int2str(iter));
% subplot(nTypes,1,n); plot(probOn{n});
% assert(~any(isnan(probOn{n})));
        end
% viewHeatMap(sOn,probOn,cellParams,params.imSize);
    end
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
            
            res{n,k} = reverseMap(gbkType, conversionsType, refPointType, nCoordsInds(n,:)', mp, ones(prod(nCoordsInds(n,:)), size(gbkType,2)));
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
            
            prodGbk_0 = computeProdGbk(gbkType, conversionsType, refPointType, nCoordsInds(n,:)', uGbkToFb1_0{n,k}, prodGbk_0);
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
locsUse = [ruleStruct.children(r,k)*ones(1,size(locsUse,2)); locsUse];
temp = zeros(size(gbkInds,2),1);
idGuess = 1;
for (i=1:numel(temp))
d = gbkInds(:,i) - locsUse(:,idGuess);
if (any(d > 0.001))
a=sum(abs(bsxfun(@minus,gbkInds(:,i),locsUse)),1);
id = find(a < 0.001);
else
id = idGuess;
end
if(~isempty(id))
temp(i) = probMapUse(id);
idGuess = min(id+1,size(locsUse,2));
else
idGuess = 1;
end
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