function res = viewBricks(bricks,templateStruct,imSize)
    
    res = zeros(imSize);

    for (i=1:size(bricks,2))
        
        type = bricks(2,i);
        template = templateStruct.app{type};
        template = double(template > 0.5);
        [patchRange,template] = getPatchTransformInds(bricks(:,i),template);
        
        res(patchRange(1,1):patchRange(1,2), patchRange(2,1):patchRange(2,2)) = ...
             res(patchRange(1,1):patchRange(1,2), patchRange(2,1):patchRange(2,2)) + template;
    end
    res = double(res~=0);
    
end

