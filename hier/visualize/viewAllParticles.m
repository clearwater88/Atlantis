function [res] = viewAllParticles(particles,templateStruct,imSize)
    
    nParticles = numel(particles);
    res = zeros([imSize,nParticles]);
    for (i=1:nParticles)
        res(:,:,i) = viewBricks(particles{i},templateStruct,imSize);
    end
end

