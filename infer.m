function [totalPost,samp_x,counts,like] = infer(data,qParts,locs,params)

    imSize = size(data);

    bg = qParts{end};

    like = params.bgMix*((bg.^data).*((1-bg).^(1-data)));
    counts = params.bgMix*ones(size(data));
    samp_x = [];
    totalPost = 1;
    
    [patches,patchCounts] = getAppPatches(qParts{1},params);
    
    tic
    patchLikes = getPatchLikes(patches,data,locs,patchCounts);
    toc
        
    nSamps = 1;
    while(1)
        
        oldSamps = discretesample(totalPost,params.postParticles);
        uniqueOldSamp = unique(oldSamps);
        nOldSamp = zeros(numel(uniqueOldSamp),1);
        for (j=1:numel(uniqueOldSamp))
            nOldSamp(j) = sum(uniqueOldSamp(j) == oldSamps);
        end
        
        likeRatio = getLikeRatio(patchLikes,patchCounts,counts(:,:,uniqueOldSamp),like(:,:,uniqueOldSamp),locs);
        logLikeRatioPatch = getLLRatioPatch(likeRatio,locs,imSize);
        
        saliencyScore = getSaliencyScore(logLikeRatioPatch,nOldSamp,locs,imSize,params);
        [sc,i] = max(saliencyScore(:));
        
        [y,x] = ind2sub(size(saliencyScore),i);
        sc
        
         [totalPost,samp_x,counts,like] = ...
             samplePosterior2(params,patchLikes,patchCounts,logLikeRatioPatch,samp_x,[y,x],uniqueOldSamp,nOldSamp,totalPost,counts,like,locs);
                
%         [totalPost,samp_x,counts,like] = ...
%             samplePosterior(params,patchLikes,patchCounts,counts,like,totalPost,samp_x,[y,x],locs);
         
        nSamps = nSamps+1;
        
        sampOn = samp_x(:,end) ~= params.sampOffFlag;
        probOn = sum(totalPost(sampOn));
        probOn
        
        if (probOn < params.probOnThresh)
            break
        else
            nOn = sum(samp_x(:,end) ~= params.sampOffFlag);
            display(sprintf('Particles made on: %d/%d', nOn,size(samp_x,1)));
        end
        
        
%         figure(100);
%         imshow(data);
%     
%         figure(2); viewSamples(samp_x,params.partSizes,imSize,totalPost);

    end

end


