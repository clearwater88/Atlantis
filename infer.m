function [totalLike,samp_x,counts,like] = infer(data,qParts,locs,params)

    bg = qParts{end};

    like = params.bgMix*((bg.^data).*((1-bg).^(1-data)));
    counts = params.bgMix*ones(size(data));
    samp_x = [];
    totalLike = 1;
    
    [patches,patchCounts] = getAppPatches(qParts{1},params);
    
    tic
    patchLikes = getPatchLikes(patches,data,locs,patchCounts);
    toc
    
    figure(100);
    imshow(data);
    
    nSamps = 1;
    while(1)
        nSalSample = min(params.salientSample,size(counts,3));
        salSamp = discretesample(totalLike,nSalSample);
        tic
        likeRatio = getLikeRatio(patchLikes,patchCounts,counts(:,:,salSamp),like(:,:,salSamp),locs);
        toc
        saliencyScore = getSaliencyScore(likeRatio);
        [sc,i] = max(saliencyScore);
        
        
        sc
        if((sc<params.salientLogThresh && nSamps > 5) || nSamps > 10)
            break;
        end
        
        [totalLike,samp_x,counts,like] = ...
            samplePosterior(params, data,qParts,params.partSizes,locs(i,:), ...
                            totalLike,like,samp_x,counts);
        nSamps = nSamps+1;
    end

end


