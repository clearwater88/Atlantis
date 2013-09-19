function [params] = initParams()
    
    params.probRoot = 0.0000001; %epsilon
    params.bpIter = 10;
    params.nParticles = 5;
    params.thingsToSee=75;
    params.emIters = 5;
    
    % start,increment,end
    % angles are -pi:pi
    params.angles = -pi:pi/8:pi-0.00001;

    params.dataFolder = '../BSDSdata/';
%     params.downSampleFactor = 4;
    

    % for computing image likelihoods. In pixels. All angles used
    params.evalLikeDims = [50,50];

    params.toString = @toString;
end


function [res] = toString(params)
    res = ['ds', int2str(params.downSampleFactor)];
end
