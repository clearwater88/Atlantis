function viewPoseDist(probMapPixels, figNum)
    nAngles = size(probMapPixels,3);
    
    y = 4;
    x = ceil(nAngles/y);
    
    if (nargin < 2)
        figure;
    else
        figure(figNum)
    end
    
    for (i=1:nAngles)
        subplot(y,x,i); imagescGray(probMapPixels(:,:,i));
    end
end

