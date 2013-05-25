function [params] = initParams()
    
    params.probRoot = 0.01; %epsilon
    params.nParticles = 10;
    
    % start,increment,end
    params.angleDisc = [-pi,pi/8,pi];

    params.dataFolder = '../BSDSdata/';
    params.downSampleFactor = 16;
    
end


