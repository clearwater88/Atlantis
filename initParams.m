function [params] = initParams()

    %actual sizes are 2* + 1
    params.partSizes(1,:) = [8,2];    
%     params.partSizes(2,:) = [2,2];
%     params.partSizes(3,:) = [4,4];
    
    params.nParts = size(params.partSizes,1);
    
    params.qFidel = 0.01;
    params.qIter = 3;
    
    % std devs to use for sampling particle locations
    params.brickStd=[0.5,0.5,pi/10];
    params.brickOn = 0.05;
    params.postParticles = 200;
    params.postXSamples = 100;
    
    params.salientLogThresh = log(1/10);
end

