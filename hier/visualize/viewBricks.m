function res = viewBricks(bricks,poseCellLocs,templateStruct,imSize)
    
    res = zeros(imSize);
    
    bricksOn = bricks(:,bricks(1,:) == 1);
    for (i=1:size(bricksOn,2))
        
        type = bricksOn(2,i);
        template = templateStruct.app{type};
        template = double(template > 0.5);
        [patchRange,template] = getPatchTransformInds(bricksOn(:,i),poseCellLocs,template);
        
        res(patchRange(1,1):patchRange(1,2), patchRange(2,1):patchRange(2,2)) = ...
             res(patchRange(1,1):patchRange(1,2), patchRange(2,1):patchRange(2,2)) + template;
    end
    res = double(res~=0);
    
end

