function [res] = getImStack(x,patchSize,stride)

    nY = floor((size(x,1)-patchSize(1))/stride + 1);
    nX = floor((size(x,2)-patchSize(2))/stride + 1);
    
    res = zeros([patchSize,size(x,3),nX*nY]);
    
    for (i=1:nX)
        for (j=1:nY)
            yStart = 1+stride*(j-1);
            xStart = 1+stride*(i-1);
            res(:,:,:,(j-1)*nX+i) = x(yStart:yStart+patchSize(1)-1, ...
                                      xStart:xStart+patchSize(2)-1,:);
        end
    end

end

