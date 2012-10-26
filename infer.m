function [totalLike,samp_x,counts,like] = infer(data,qParts,locs,params)
    
    
    patches = getAppPatches(qParts{1},params);
    
    
    
    bg = qParts{end};
    
    
    
    
    like = params.bgMix*((bg.^data).*((1-bg).^(1-data)));
    counts = params.bgMix*ones(size(data));
    samp_x = [];
    totalLike = 1;
    
    salient = getSaliencyMap(data,qParts);
    [salientLocs,locsScore] = orderSalient(salient,locs);
    
    goodLocs = locsScore>params.salientLogThresh;
    salientLocs = salientLocs(goodLocs,:);
    
    MAXP = size(salientLocs,1);
    assert(MAXP > 1);
    
  %  figure(1); imshow(data);
    for (i=1:MAXP)
        display(sprintf('%d / %d',i,MAXP));
        [totalLike,samp_x,counts,like] = ...
            samplePosterior(params, data,qParts,params.partSizes,salientLocs(i,:), ...
                            totalLike,like,samp_x,counts);

    end

end


