function [cellMapStruct] = getAllProbMapCells(cellParams,probMapStruct,ruleStruct,params,imSize)
% probMap = cell(nRules,maxSlots,maxAngles);

    nRules = numel(ruleStruct.parents);
    maxSlots = max(sum(ruleStruct.children~=0,2));    

    maxAngles = 0;
    for (i=1:size(cellParams.strides,1))
       maxAngles = max(maxAngles,round(2*pi/cellParams.strides(i,3)));
    end
    
    probMap = cell(nRules,maxSlots,maxAngles);
    probMapSpatial = cell(nRules,maxSlots,maxAngles);
    resPixels = cell(nRules,maxSlots,maxAngles);
    locs = cell(nRules,maxSlots,maxAngles);
    
    % find reference point
    refPointsTemp = zeros(cellParams.nTypes,2);
    imCentre = floor((imSize+1)/2);
    for (n=1:cellParams.nTypes)
        locsUse = cellParams.centres{n};          
        diff = sum(bsxfun(@minus,locsUse(:,1:2),imCentre).^2,2);
        [~,temp] = min(diff);
        refPointsTemp(n,:) = locsUse(temp,1:2);
    end
    
    angles = cell(cellParams.nTypes,1);
    for (n=1:cellParams.nTypes)
        angles{n} = unique(cellParams.centres{n}(:,3));
    end
    
    childType = zeros(nRules,maxSlots);
    parentType = zeros(nRules,1);
    % easier to work with if we just replicate the refpoints
    refPoints = zeros(2,nRules,maxSlots);

    for (ruleId=1:nRules)

        type = ruleStruct.parents(ruleId);
        parentType(ruleId) = type;
        
        ch = ruleStruct.children(ruleId,:);
        nSlots = sum(ch~=0);
                
        nAngles = numel(angles{type});
        
        for (slot=1:nSlots)
            chType = ch(slot);
            childType(ruleId,slot) = chType;
            
            refPoints(:,ruleId,slot) = ...
                centre2CellFrame(refPointsTemp(type,:), ...
                cellParams.strides(type,1:2), ...
                cellParams.origins(type,1:2));
            assert(~any(abs(mod(refPoints(:,ruleId,slot),1)) > 0.0001));
            
            for (a=1:nAngles)
                [probMapTemp,locsTemp,resPixelsTemp]= ...
                    getProbMapCells(ruleId,slot, chType, ...
                    [refPointsTemp(type,:)';angles{type}(a)]', ...
                    probMapStruct, ...
                    imSize,params.angles, ...
                    cellParams);
                
                probMap{ruleId,slot,a} = probMapTemp;
                locs{ruleId,slot,a} = locsTemp;
                resPixels{ruleId,slot,a}=resPixelsTemp;
                 
                 % may not be symmetric; depends on how gridding of parent 
                 % and child centres align
                 probMapSpatial{ruleId,slot,a} = ...
                     reshape(probMapTemp,max(locsTemp)-min(locsTemp)+1);
            end
        end
    end
    cellMapStruct.probMap = probMap;
    cellMapStruct.probMapSpatial = probMapSpatial;
    cellMapStruct.locs = locs; % in coords of child
    cellMapStruct.refPoints = refPoints; % in coords of parent
    cellMapStruct.parentType=parentType;
    cellMapStruct.childType=childType;
    cellMapStruct.angles = angles;
end

