function [cellMapStruct] = getAllProbMapCells2(cellParams,probMapStruct,ruleStruct,params)
    % resPixels: probMap across pixels. [imSize x nAngles] per each element
    %            of cell array

    cellCentres = cellParams.centres;

    nRules = numel(ruleStruct.parents);
    maxSlots = max(sum(ruleStruct.children~=0,2));    
   
    angles = params.angleDisc(1):params.angleDisc(2):params.angleDisc(3);
    nAngles = numel(angles);
    
    probMap = cell(nRules,maxSlots,nAngles);
    locs = cell(nRules,maxSlots,nAngles);
    
    %probMap = cell(nRules,maxSlots,numel(angles));
    %locInds = cell(nRules,maxSlots,numel(angles));
    refPointsTemp = zeros(cellParams.nTypes,2);
    
    % find reference point
    imCentre = (params.imSize+1)/2;
    for (n=1:cellParams.nTypes)
        locsUse = cellCentres{n};          
        diff = sum(bsxfun(@minus,locsUse(:,1:2),imCentre).^2,2);
        [~,temp] = min(diff);
        refPointsTemp(n,:) = locsUse(temp,1:2);
    end
    
    childType = zeros(nRules,maxSlots);
    
    % easier to work with if we just replicate the refpoints
    refPoints = zeros(2,nRules,maxSlots);
    for (ruleId=1:nRules)

        type = ruleStruct.parents(ruleId);
        
        ch = ruleStruct.children(ruleId,:);
        nSlots = sum(ch~=0);
                
        tic
        for (slot=1:nSlots)
            chType = ch(slot);
            childType(ruleId,slot) = chType;
            refPoints(:,ruleId,slot) = refPointsTemp(type,:);
            
            for (a=1:nAngles)
                [probMap{ruleId,slot,a},locs{ruleId,slot,a}]= ...
                    getProbMapCells2(ruleId,slot, chType, ...
                                     [refPoints(:,ruleId,slot);angles(a)]', ...
                                     probMapStruct, ...
                                     params.imSize,params.angleDisc, ...
                                     cellParams);
                 
                    
            end
        end
        toc
    end
    cellMapStruct.probMap = probMap;
    cellMapStruct.locs = locs;
    cellMapStruct.refPoints = refPoints;
    cellMapStruct.childType=childType;
    cellMapStruct.angles = angles;
end

