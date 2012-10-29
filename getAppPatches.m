function [res,counts] = getAppPatches(part,params)

    partSize = size(part);
    maxDim = max(partSize);
    
    res = padarray(part,[maxDim-partSize]/2);
    res = repmat(res,[1,1,numel(params.orientationsUse)]);
    
    for (i=1:numel(params.orientationsUse))
        % convert to degrees, do negative to be consistent with rotation
        % direction in rest of code
       res(:,:,i) = imrotate(res(:,:,i),-180*params.orientationsUse(i)/pi,'nearest','crop');
    end
    counts = res>0;
end