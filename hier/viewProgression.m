function viewProgression(data,particles,params,templateStruct,imSize,fignum)
    
    if(isempty(fignum))
       fignum=200; 
    end

    [rotTemplates,~] = getRotTemplates(params,templateStruct);
    
    nThings = size(particles{1},2);
    sz(1) = ceil(sqrt(nThings));
    sz(2) = ceil(nThings/sz(1));
       
    for (i=1:nThings)
       particlesUse = cell(size(particles)); 
       for (n=1:numel(particles))
          particlesUse{n} = particles{n}(:,1:i); 
       end
       
       figure(fignum);
       %subplot(sz(1),sz(2),i);  imshow(viewAllParticles(particlesUse,rotTemplates,params,imSize));
       
       subplot(sz(1),sz(2),i); imshow(viewOverlayTest(data,particlesUse,rotTemplates,params,imSize));
%        imshowFull(viewOverlayTest(data,particlesUse,rotTemplates,params,imSize));
%        title(int2str(i));
%        pause
    end
    
    
end

