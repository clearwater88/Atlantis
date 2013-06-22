function [cellMapStruct] = getAllProbMapCells2(cellParams,probMapStruct,ruleStruct,params)
    % resPixels: probMap across pixels. [imSize x nAngles] per each element
    %            of cell array

    cellCentres = cellParams.centres;

    nRules = numel(ruleStruct.parents);
    maxSlots = max(sum(ruleStruct.children~=0,2));    
   
    angles = params.angleDisc(1):params.angleDisc(2):params.angleDisc(3);
    

    
    maxLocs = 0;
    temp = sum(ruleStruct.children~=0,2)~=0;    
    typePars = unique(ruleStruct.parents(temp));
    for (n=1:numel(typePars))
       maxLocs  = max(maxLocs, size(cellCentres{typePars(n)},1));
    end
    
    probMap = cell(nRules,maxSlots,maxLocs);
    locInds = cell(nRules,maxSlots,maxLocs);
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
            
            locsUse = cellCentres{type};
            tic
            
            for (loc=1:size(locsUse,1))
                [probMap{ruleId,slot,loc},locInds{ruleId,slot,loc}]= ...
                    getProbMapCells2(ruleId,slot,locsUse(loc,:), ...
                    probMapStruct, ...
                    params.imSize,params.angleDisc, ...
                    cellParams.centreBoundaries{chType});
            end
                
%             for (a=1:numel(angles))
%                 [probMap{ruleId,slot,a},locInds{ruleId,slot,a}]= ...
%                     getProbMapCells2(ruleId,slot, ...
%                                      [refPoints(type,:),angles(a)], ...
%                                      probMapStruct, ...
%                                      params.imSize,params.angleDisc, ...
%                                      cellParams.centreBoundaries{chType});
%             end
        end
        toc
    end
    cellMapStruct.probMap = probMap;
    cellMapStruct.locInds = locInds;
    cellMapStruct.refPoints = refPoints;
end

