function [params] = initParams()
    params.partSizes(1,:) = [8,8];
    params.partSizes(2,:) = [12,4];
    params.nParts = size(params.partSizes,1);
    
    params.qFidel = 0.01;
    params.qIter = 10;
end

