function [res] = getBrickLoc(imSize,params)

    maxSize = max(params.partSizes,[],1);

    % Every brick can be at every pixel location, except at borders
    temp = [1:prod(imSize)]';
    [y,x] = ind2sub(imSize, temp);
    res = [y,x];
    
    res(res(:,1) < maxSize(1)+1,:) = [];
    res(res(:,1) > imSize(1) - maxSize(1),:) = [];
   
    res(res(:,2) < maxSize(2)+1,:) = [];
    res(res(:,2) > imSize(2) - maxSize(2),:) = [];
    
end

