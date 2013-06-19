function [res,resPixels] = getAllProbMapCells(cellParams,probMapStruct,ruleStruct,params)
    % resPixels: probMap across pixels. [imSize x nAngles] per each element
    %            of cell array

    cellCentres = cellParams.centres;
    cellDims = cellParams.dims;

    nRules = numel(ruleStruct.parents);
    maxSlots = max(sum(ruleStruct.children~=0,2));
    maxLocs = 0;
    
    temp = sum(ruleStruct.children~=0,2)~=0;
    
    typePars = unique(ruleStruct.parents(temp));
    for (n=1:numel(typePars))
       maxLocs  = max(maxLocs, size(cellCentres{typePars(n)},1));
    end
    
    res = cell(nRules,maxSlots,maxLocs);
    resPixels = cell(nRules,maxSlots,maxLocs);
     
    for (ruleId=1:nRules)
        
        type = ruleStruct.parents(ruleId);
        ch = ruleStruct.children(ruleId,:);
        nSlots = sum(ch~=0);
        
        locsUse = cellCentres{type};
        tic
        for (slot=1:nSlots)
            chType = ch(slot);            
            for (loc=1:size(locsUse,1))       
                [res{ruleId,slot,loc}, resPixels{ruleId,slot,loc} ]= ...
                    getProbMapCells(ruleId,slot,locsUse(loc,:), ...
                                    probMapStruct, ...
                                    params.imSize,params.angleDisc, ...
                                    cellCentres{chType}, cellDims(chType,:));
            end
        end
        toc
        
    end     
end

