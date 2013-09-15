function res = viewBricks(bricks,templates,params,imSize)
   
    %ags = params.angleDisc(1):params.angleDisc(2):params.angleDisc(3);
    ags = params.angles;
    
    res = zeros(imSize);
    for (i=1:size(bricks,2))
        isOn = getOn(bricks,i);
        if(~isOn) continue; end;

        type = getType(bricks,i);
        
        pose = bricks(4:6,i);
        angle= pose(3);
        [~,agInd] = min(abs(angle-ags));
        rotTemplate = templates{type,agInd};
        
        patchRange(:,1) = (pose(1:2)'-(size(rotTemplate)-1)/2)';
        patchRange(:,2) = (pose(1:2)'+(size(rotTemplate)-1)/2)';
        
        res(patchRange(1,1):patchRange(1,2), patchRange(2,1):patchRange(2,2)) = ...
              res(patchRange(1,1):patchRange(1,2), patchRange(2,1):patchRange(2,2)) + rotTemplate;
    end
    res = double(res);
end

