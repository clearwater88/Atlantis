function [params] = initParams()
    
    params.probRoot = 0.0001; %epsilon
    params.nParticles = 1;
    
    % start,increment,end
    params.angleDisc = [-pi,pi/8,pi];

    params.dataFolder = '../BSDSdata/';
    params.downSampleFactor = 8;
    
end


