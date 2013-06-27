function [params] = initParams()
    
    params.probRoot = 0.0001; %epsilon
    params.nParticles = 20;
    
    % start,increment,end
    % angles are -pi:pi
    params.angleDisc = [-pi,pi/8,pi-0.00001];

    params.dataFolder = '../BSDSdata/';
    params.downSampleFactor = 4;
    
    params.toString = @toString;
end


function [res] = toString(params)
    res = ['ds', int2str(params.downSampleFactor)];
end
