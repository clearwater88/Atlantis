function [res] = getBrickLoc(imSize,partSizes)

    maxSpread = max(partSizes(:));

    % Every brick can be at every pixel location, except at borders
    temp = [1:prod(imSize)]';
    [y,x] = ind2sub(imSize, temp);
    res = [y,x];
    
    res(res(:,1) < maxSpread+1,:) = [];
    res(res(:,1) > imSize(1) - maxSpread,:) = [];
   
    res(res(:,2) < maxSpread+1,:) = [];
    res(res(:,2) > imSize(2) - maxSpread,:) = [];
end

