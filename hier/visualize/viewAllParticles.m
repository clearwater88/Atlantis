function [res] = viewAllParticles(particles,templateStruct,params)

    nParticles = numel(particles);
    res = zeros(params.imSize);
    
    [templates,~] = getRotTemplates(params,templateStruct);
    
    for (i=1:nParticles)
        res = res + viewBricks(particles{i},templates,params)/nParticles;
    end
    
end