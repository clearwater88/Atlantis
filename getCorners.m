function [res] = getCorners(params,gtBrick)

    % gtBrick: [nIm,nParts,maxParts,centre]
    INVALID_FLAG = -1;
    
    nParts = size(gtBrick,2);
    
    temp = size(gtBrick);    
    res = -1*ones([temp(1:3),4]);
    
    invalid = zeros(temp(1:3));
    for (p=1:nParts)
        toUse = gtBrick(:,p,:,:);
        
        partSize = params.partSizes(p,:);
        
        res(:,p,:,1) = toUse(:,:,:,1) - partSize(1);
        res(:,p,:,2) = toUse(:,:,:,1) + partSize(1);
        res(:,p,:,3) = toUse(:,:,:,2) - partSize(2);
        res(:,p,:,4) = toUse(:,:,:,2) + partSize(2);
        
        invalid(:,p,:) = (toUse(:,:,:,1) == INVALID_FLAG | ...
                          toUse(:,:,:,2) == INVALID_FLAG);
    end
    
    % Set non-existent boxes for invalid box corners
    temp = size(gtBrick);
    res = reshape(res,prod(temp(1:3)),4);
    invalid = boolean(invalid(:));
    res(invalid,1) = 1; res(invalid,2) = 0; 
    res(invalid,3) = 1; res(invalid,4) = 0;
    res = reshape(res,[temp(1:3),4]);    
end

