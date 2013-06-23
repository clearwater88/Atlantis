function [cellMapStruct] = getAllProbMapCells2(cellParams,probMapStruct,ruleStruct,params)
    % resPixels: probMap across pixels. [imSize x nAngles] per each element
    %            of cell array

    cellCentres = cellParams.centres;

    nRules = numel(ruleStruct.parents);
    maxSlots = max(sum(ruleStruct.children~=0,2));    
   
    angles = params.angleDisc(1):params.angleDisc(2):params.angleDisc(3);
    nAngles = numel(angles);
    
    probMap = cell(nRules,maxSlots,nAngles);
    locInds = cell(nRules,maxSlots,nAngles);
    %probMap = cell(nRules,maxSlots,numel(angles));
    %locInds = cell(nRules,maxSlots,numel(angles));
    refPoints = zeros(cellParams.nTypes,2);
    
    % find reference point
    imCentre = (params.imSize+1)/2;
    for (n=1:cellParams.nTypes)
        locsUse = cellCentres{n};          
        diff = sum(bsxfun(@minus,locsUse(:,1:2),imCentre).^2,2);
        [~,temp] = min(diff);
        refPoints(n,:) = locsUse(temp,1:2);
    end
    
    for (ruleId=1:nRules)
        
        type = ruleStruct.parents(ruleId);
        ch = ruleStruct.children(ruleId,:);
        nSlots = sum(ch~=0);
                
        tic
        for (slot=1:nSlots)
            chType = ch(slot);
                
            for (a=1:nAngles)
                [probMap{ruleId,slot,a},locInds{ruleId,slot,a}]= ...
                    getProbMapCells2(ruleId,slot, ...
                                     [refPoints(type,:),angles(a)], ...
                                     probMapStruct, ...
                                     params.imSize,params.angleDisc, ...
                                     cellParams.centreBoundaries{chType});
            end
        end
        toc
    end
    cellMapStruct.probMap = probMap;
    cellMapStruct.locInds = locInds;
    cellMapStruct.refPoints = refPoints;
end

