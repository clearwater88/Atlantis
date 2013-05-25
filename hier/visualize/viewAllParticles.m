function [res] = viewAllParticles(particles,templateStruct,imSize,figNum)
    
    if(nargin < 4) figNum = 100; end;

    nParticles = numel(particles);
    res = zeros([imSize,nParticles]);
    for (i=1:nParticles)
        res(:,:,i) = viewBricks(particles{i},templateStruct,imSize);
    end
    
    for (i=1:nParticles)
        figure(figNum);
        imagesc(res(:,:,i)); colormap(gray); axis off;
    end
end

