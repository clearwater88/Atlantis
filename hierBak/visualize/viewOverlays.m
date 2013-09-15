function res = viewOverlays( particles, templateStruct, params, allConnPars, figNum)

    if (nargin < 5)
        figNum = 1;
    end
    
    nParticle = numel(particles);
    for (i=1:nParticle)
        st = viewAllParticles(particles(i),templateStruct,params.imSize);
        v = viewConnectivity(particles{i},allConnPars{i},params.imSize,st);
        res(:,:,:,i) = v;
    end
    
    
    figure(figNum);
    for (i=1:nParticle)
        subplot(4,ceil(nParticle/4),i);
        imshow(res(:,:,:,i));        
    end
    
end

