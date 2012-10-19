function [totalLike,samp_x,counts,likeFg] = infer(data,qParts,locs,params)


    partSize =  params.partSizes(1,:);
    
    % For now, iterate in order
    
    samp_x = [];
    counts = [];
    likeFg = [];
    totalLike = [];
    
    salient = getSaliencyMap(data,qParts);
    [salientLocs,locsScore] = orderSalient(salient,locs);
    
    goodLocs = locsScore>params.salientLogThresh;
    salientLocs = salientLocs(goodLocs,:);
    
    MAXP = size(salientLocs,1);
    assert(MAXP > 1);
    
    for (i=1:MAXP)
        display(sprintf('%d / %d',i,MAXP));
        [totalLike,samp_x,counts,likeFg] = ...
            samplePosterior(params, data,qParts,partSize,salientLocs(i,:), ...
                            totalLike,likeFg,samp_x,counts);
    end

end


