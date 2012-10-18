function [particles] = infer(data,qParts,locs,params)

    MAXP = size(locs,1);
    partSize =  params.partSizes(1,:);
    
    % For now, iterate in order
    
    samp_x = [];
    counts = [];
    likeFg = [];
    totalLike = [];
    
    for (i=1:MAXP)
        display(sprintf('%d / %d',i,MAXP));
        [totalLike,samp_x,counts,likeFg] = ...
            samplePosterior(params, data,qParts,partSize,locs(i,:), ...
                            totalLike,likeFg,samp_x,counts);
    end


particles = 0;

end


