function [params] = initParams()
    
    params.brickOn = 0.01;
    params.nParticles = 50;
    
    % start,increment,end
    params.angleDisc = [0,pi/16,2*pi];
    % std devs to use for sampling particle locations
%     params.mixPropFact = 2;
%     params.bgMix = 0.01;
% 
%     params.brickStd=0.1;
%     params.brickOn = 0.01;
%     params.postParticles = 50;
%     params.orientPriorStep = pi/4;
%     
%     params.orientUse = [0:pi/32:2*pi]';
%     params.sampOffFlag = -10;
%     params.probOnThresh = 0.3;
end


