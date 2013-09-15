function [cellMapStruct] = getAllProbMapCells(cellParams,probMapStruct,ruleStruct,params,imSize)
    % resPixels: probMap across pixels. [imSize x nAngles] per each element
    %            of cell array

    cellCentres = cellParams.centres;

    nRules = numel(ruleStruct.parents);
    maxSlots = max(sum(ruleStruct.children~=0,2));    

    maxAngles = 0;
    for (i=1:size(cellParams.strides,1))
       maxAngles = max(maxAngles,round(2*pi/cellParams.strides(i,3)));
    end
    
    probMap = cell(nRules,maxSlots,maxAngles);
    probMapSpatial = cell(nRules,maxSlots,maxAngles);
    locs = cell(nRules,maxSlots,maxAngles);
    
    %probMap = cell(nRules,maxSlots,numel(angles));
    %locInds = cell(nRules,maxSlots,numel(angles));
    refPointsTemp = zeros(cellParams.nTypes,2);
    
    % find reference point
    imCentre = (imSize+1)/2;
    for (n=1:cellParams.nTypes)
        locsUse = cellCentres{n};          
        diff = sum(bsxfun(@minus,locsUse(:,1:2),imCentre).^2,2);
        [~,temp] = min(diff);
        refPointsTemp(n,:) = locsUse(temp,1:2);
    end
    
    angles = cell(cellParams.nTypes,1);
    for (n=1:cellParams.nTypes)
        angles{n} = unique(cellParams.centres{n}(:,3));
    end
    
    childType = zeros(nRules,maxSlots);
    parentType = zeros(nRules);
    % easier to work with if we just replicate the refpoints
    refPoints = zeros(2,nRules,maxSlots);

    for (ruleId=1:nRules)

        type = ruleStruct.parents(ruleId);
        parentType(ruleId) = type;
        
        ch = ruleStruct.children(ruleId,:);
        nSlots = sum(ch~=0);
                
        nAngles = numel(angles{type});
        
        tic
        for (slot=1:nSlots)
            chType = ch(slot);
            childType(ruleId,slot) = chType;
            
            refPointPixel = refPointsTemp(type,:);
            refPoints(:,ruleId,slot) = ...
                centre2CellFrame(refPointsTemp(type,:), ...
                cellParams.strides(type,1:2), ...
                cellParams.origins(type,1:2));
            assert(~any(abs(mod(refPoints(:,ruleId,slot),1)) > 0.0001));
            
            for (a=1:nAngles)
                [probMapTemp,locsTemp]= ...
                    getProbMapCells(ruleId,slot, chType, ...
                                    [refPointPixel';angles{type}(a)]', ...
                                    probMapStruct, ...
                                    imSize,params.angles, ...
                                    cellParams);
                                 
                 probMap{ruleId,slot,a} = probMapTemp;
                 locs{ruleId,slot,a} = locsTemp;

                 rg = max(locsTemp)-min(locsTemp)+1;
                 % may not be symmetric; depends on how gridding of parent 
                 % and child centres align
                 probMapSpatial{ruleId,slot,a} = reshape(probMapTemp,rg);
                 [val] = max(probMapSpatial{ruleId,slot,a},[],3);
                 temp = probMapSpatial{ruleId,slot,a}(:,:,a);
                 assert(~any(val(:)-temp(:) > 0.001));
            end
        end
        toc
    end
    
    cellMapStruct.probMap = probMap;
    cellMapStruct.probMapSpatial = probMapSpatial;
    cellMapStruct.locs = locs; % in coords of child
    cellMapStruct.refPoints = refPoints; % in coords of parent
    cellMapStruct.parentType=parentType;
    cellMapStruct.childType=childType;
    cellMapStruct.angles = angles;
end

