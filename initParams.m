function [params] = initParams()

    %actual sizes are 2* + 1
    params.partSizes(1,:) = [3,1];
    params.partSizes(2,:) = [2,2];
    params.partSizes(3,:) = [4,4];
    
    params.nParts = size(params.partSizes,1);
    
    params.qFidel = 0.01;
    params.qIter = 3;
end

