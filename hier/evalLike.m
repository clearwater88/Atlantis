function [like,counts] = evalLike(data,bricks,like,counts,templateStruct)
    
    bricksOn = bricks(:,bricks(1,:) == 1);
        
    for (i=1:size(bricksOn,2))
        type = bricksOn(2,i);
        [patchRange,template] = getPatchTransformInds(bricksOn(:,i),templateStruct.app{type});
    
        dataUse = data(patchRange(1,1):patchRange(1,2), ...
                       patchRange(2,1):patchRange(2,2));
        likePatch = templateStruct.mix(type)*((template.^dataUse).*((1-template).^(1-dataUse)));
        
        like(patchRange(1,1):patchRange(1,2), patchRange(2,1):patchRange(2,2)) = ...
             like(patchRange(1,1):patchRange(1,2), patchRange(2,1):patchRange(2,2)) + likePatch;
        
        counts(patchRange(1,1):patchRange(1,2), patchRange(2,1):patchRange(2,2)) = ...
             counts(patchRange(1,1):patchRange(1,2), patchRange(2,1):patchRange(2,2)) + templateStruct.mix(type);
         
    end
   
end

