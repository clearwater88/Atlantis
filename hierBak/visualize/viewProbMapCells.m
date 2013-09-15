function viewProbMapCells(cellParams,cellMapStruct,ruleId,slot,agInd)
    chType = cellMapStruct.childType(ruleId,slot);
    parType = cellMapStruct.parentType(ruleId,slot);
    
    probMap = cellMapStruct.probMapSpatial(ruleId,slot,agInd);
    probMap = cell2mat(probMap);
    
    coords = cellParams.coords{chType};
    locs = cellMapStruct.locs{ruleId,slot,agInd};

    parent2childScale = cellParams.strides(parType,1:2)./cellParams.strides(chType,1:2);
    
    centres = cellParams.centres{chType};
    
    for (i=1:size(coords,1))
       coordsUse = coords(i,:);
       ag = coordsUse(3);
       locsUse = locs(locs(:,3)==ag,:);
       
       probMapUse = probMap(:,:,ag);
       toShift = coordsUse(1:2)-refPointChildFrame;
    end
    error('not done');
end

