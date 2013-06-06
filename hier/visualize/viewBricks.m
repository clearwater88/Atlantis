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

% 
% function [likes,counts] = viewBricks(testData,bricks,templateStruct)
% 
%     counts = templateStruct.mix(end).*ones(size(testData));
%     likes = templateStruct.mix(end)*(templateStruct.app{end}.^testData).*((1-templateStruct.app{end}).^(1-testData));
%     
%     for (i=1:size(bricks,2))
%         isOn = getOn(bricks,i);
%         if(~isOn) continue; end;
% 
%         type = getType(bricks,i);
%         template = templateStruct.app{type};
%         
%         pose = bricks(4:6,i);
%         [bd,rotTemplate,templateMask] = getPatchTransformInds(template, pose');
%         
%         dataUse = testData(bd(1,1):bd(1,2), bd(2,1):bd(2,2));
% 
%         likePatch = templateStruct.mix(type)*((rotTemplate.^dataUse).*((1-rotTemplate).^(1-dataUse)));
%         countPatch = templateStruct.mix(type)*ones(size(rotTemplate));
%         likePatch = likePatch.*templateMask;
%         countPatch = countPatch.*templateMask;
%                     
%         counts(bd(1,1):bd(1,2), bd(2,1):bd(2,2)) = ...
%             counts(bd(1,1):bd(1,2), bd(2,1):bd(2,2)) + countPatch;
%         
%         likes(bd(1,1):bd(1,2), bd(2,1):bd(2,2)) = ...
%             likes(bd(1,1):bd(1,2), bd(2,1):bd(2,2)) + likePatch;
%     end
% end
