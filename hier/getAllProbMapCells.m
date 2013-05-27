function [res] = getAllProbMapCells(cellParams,probMapStruct,ruleStruct,params)

    cellCentres = cellParams.centres;
    cellDims = cellParams.dims;

    for (ruleId=1:numel(ruleStruct.parents))
        
        type = ruleStruct.parents(ruleId);
        ch = ruleStruct.children(ruleId,:);
        nSlots = sum(ch~=0);
        
        locsUse = cellCentres{type};
        for (slot=1:nSlots)
            chType = ch(slot);            
            for (loc=1:size(locsUse,1))
                res{ruleId,slot,loc} = ...
                    getProbMapCells(ruleId,slot,locsUse(loc,:), ...
                                    probMapStruct, ...
                                    params.imSize,params.angleDisc, ...
                                    cellCentres{chType}, cellDims(chType,:));
            end
        end
        
    end     
end

