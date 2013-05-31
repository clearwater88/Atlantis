function [res] = viewAllParticles(particles,templateStruct,imSize)

    nParticles = numel(particles);
    res = zeros([imSize]);
    for (i=1:nParticles)
        res = res + viewBricks(particles{i},templateStruct,imSize)/nParticles;
    end
    
end

% function [res] = viewAllParticles(testData,particles,templateStruct,imSize,figNum)
%     
%     if(nargin < 5) figNum = 100; end;
% 
%     nParticles = numel(particles);
% 
%     res = zeros(imSize);
%     
%     for (i=1:nParticles)
%         [likes,counts] = viewBricks(testData,particles{i},templateStruct);
%         res = res + (likes./counts)/nParticles;
%     end
%     figure(figNum);
%     imshow(res); colormap(gray);
% end