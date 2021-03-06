function pGbkRStruct = computePGbkR(gBkLookUp,ruleStruct,cellMapStruct)
    % in raster order!
    % pGbkRStruct = cell(nRules,maxSlots);
    % pGbkRStruct: %nBricks x nAngles
    
    nTypes = numel(unique(ruleStruct.parents));
    maxSlots = size(ruleStruct.children,2);
    nRules = numel(ruleStruct.parents); 
    maxAngles = -1;
    for (n=1:nTypes)
       maxAngles = max(maxAngles,numel(cellMapStruct.angles{n})); 
    end
    
    pGbkRStruct = cell(nRules,maxSlots);
    idxUsed = [];
    
    for (r=1:size(ruleStruct.rules,1))
        parType = ruleStruct.parents(r);
        for (k=1:maxSlots)
            if(ruleStruct.children(r,k) ==0) continue; end;
            gbkInds = gBkLookUp{parType,k};
            tempAll = [];
            
            idxUsed = [];
            for (ag=1:numel(cellMapStruct.angles{parType}))
                probMapUse = cellMapStruct.probMap{r,k,ag};
                locsUse = [ruleStruct.children(r,k)*ones(1,size(cellMapStruct.locs{r,k,ag},1)); ...
                           cellMapStruct.locs{r,k,ag}'];
                
                temp = zeros(size(gbkInds,2),1);
                idGuess = 1;
                
                for (i=1:numel(temp))
                    d = gbkInds(:,i) - locsUse(:,idGuess);
                    if (any(abs(d) > 0.001))
                        a=sum(abs(bsxfun(@minus,gbkInds(:,i),locsUse)),1);
                        id = find(a < 0.001);
                    else
                        id = idGuess;
                    end
                    if(~isempty(id))
                        if(contains(idxUsed,id))
                            
                        end
                        idxUsed = [idxUsed,id];
                        
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

