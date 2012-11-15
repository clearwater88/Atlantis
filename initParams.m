function [params] = initParams()

    %actual sizes are 2* + 1
    %params.partSizes(1,:) = [3,1];    
%     params.partSizes(2,:) = [2,2];
%     params.partSizes(3,:) = [4,4];
    
%    params.nParts = size(params.partSizes,1);
    
    params.qFidel = 0.01;
    params.qIter = 3;
    
    % std devs to use for sampling particle locations
    params.brickStd=0.5;
    params.brickOn = 0.01;
    params.postParticles = 20;
    
    params.bgMix = 0.01;
    
    params.orientationsUse = [0:pi/15:2*pi]';
    params.sampOffFlag = -10;
    params.probOnThresh = 0.2;
end

