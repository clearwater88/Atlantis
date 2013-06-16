function [res] = viewAllParticles(particles,templateStruct,imSize)

    nParticles = numel(particles);
    res = zeros([imSize]);
    for (i=1:nParticles)
        res = res + viewBricks(particles{i},templateStruct,imSize)/nParticles;
    end
    
end