function res = viewBricks(bricks,templateStruct,imSize)

    res = zeros(imSize);
    for (i=1:size(bricks,2))
        isOn = getOn(bricks,i);
        if(~isOn) continue; end;

        type = getType(bricks,i);
        template = templateStruct.app{type};
        %template = ones(size(template));
        
        pose = bricks(4:6,i);
        [patchRange,template] = getPatchTransformInds(template, pose');
        res(patchRange(1,1):patchRange(1,2), patchRange(2,1):patchRange(2,2)) = ...
              res(patchRange(1,1):patchRange(1,2), patchRange(2,1):patchRange(2,2)) + template;
    end
    res = double(res);
end

