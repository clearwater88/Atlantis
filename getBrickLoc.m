function [res] = getBrickLoc(imSize,params)

    maxDim = max(params.partSizes(:));

    % Every brick can be at every pixel location, except at borders
    temp = [1:prod(imSize)]';
    [y,x] = ind2sub(imSize, temp);
    res = [y,x];
    
    res(res(:,1) < maxDim+1,:) = [];
    res(res(:,1) > imSize(1) - maxDim,:) = [];
   
    res(res(:,2) < maxDim+1,:) = [];
    res(res(:,2) > imSize(2) - maxDim,:) = [];
    
end

