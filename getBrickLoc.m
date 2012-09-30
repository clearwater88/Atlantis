function [res] = getBrickLoc(imSize)
    % Every brick can be at every pixel location
    temp = [1:prod(imSize)]';
    [y,x] = ind2sub(imSize, temp);
    res = [y,x];   
end

