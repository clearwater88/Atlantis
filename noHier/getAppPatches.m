function [res,counts] = getAppPatches(part,params,partNum)
    % res: [partSize, #orientations], appearnace of the patch
    % counts: [partSize, #orientations], associated count for each pixel (mixing weight)

    part = part{partNum};
    partSize = size(part);
    maxDim = max(partSize);
    
    res = padarray(part,[maxDim-partSize]/2);
    res = repmat(res,[1,1,numel(params.orientUse)]);
    
    for (i=1:numel(params.orientUse))
        % convert to degrees, do negative to be consistent with rotation
        % direction in rest of code
        res(:,:,i) = imrotate(res(:,:,i), ...
                     -180*(params.orientUse(i))/pi, ...
                     'nearest','crop');
    end
    counts = params.partMix(partNum)*double(res>0);
end