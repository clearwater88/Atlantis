function res = viewBricks(bricks,templates,params)
    
    imSize=params.imSize;
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
        
        % hacks
%         diff = patchRange(1,1) - 1;
%         if(diff < 0)
%             patchRange(1,:) = patchRange(1,:)+abs(diff)+1;
%         end
%         diff = patchRange(2,1) - 1;
%         if(diff < 0)
%             patchRange(2,:) = patchRange(2,:)+abs(diff)+1;
%         end
%         diff = imSize(1) - patchRange(1,2);
%         if(diff < 0)
%             patchRange(1,:) = patchRange(1,:)-abs(diff)-1;
%         end
%         diff = imSize(2) - patchRange(2,2);
%         if(diff < 0)
%             patchRange(2,:) = patchRange(2,:)-abs(diff)-1;
%         end
        % hacks
        
        res(patchRange(1,1):patchRange(1,2), patchRange(2,1):patchRange(2,2)) = ...
              res(patchRange(1,1):patchRange(1,2), patchRange(2,1):patchRange(2,2)) + rotTemplate;
    end
    res = double(res);
end

