%function [res] = viewAllParticles(particles,templateStruct,params)
function [res] = viewAllParticles(particles,templates,params)

    nParticles = numel(particles);
    res = zeros(params.imSize);
    
    %[templates,~] = getRotTemplates(params,templateStruct);
    
    for (i=1:nParticles)
        res = res + viewBricks(particles{i},templates,params)/nParticles;
    end
    
end