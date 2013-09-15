function [res] = viewAllParticles(particles,templates,params,imSize)

    nParticles = numel(particles);
    res = zeros(imSize);
    
    %[templates,~] = getRotTemplates(params,templateStruct);
    
    for (i=1:nParticles)
        res = res + viewBricks(particles{i},templates,params,imSize)/nParticles;
    end
    
end