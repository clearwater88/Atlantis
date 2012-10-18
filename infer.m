function [particles] = infer(data,qParts,locs,params)

    MAXP = size(locs,1);
    partSize =  params.partSizes(1,:);
    
    % For now, iterate in order
    
    totalLike = [];
    samp_x = [];
    countMask = [];
    likeIm = [];
    for (i=1:MAXP)
        
        [totalLike,samp_x,countMask,likeIm] = ...
            samplePosterior(params, data,qParts,partSize,locs(i,:), ...
                            totalLike,samp_x,countMask,likeIm);
    end


particles = 0;

end


