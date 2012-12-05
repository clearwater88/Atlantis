function [totalPost,samp_x,counts,like] = infer(data,qParts,params)

    imSize = size(data);

    bg = qParts{end};

    % Initialize background model mixture component    
    like = params.bgMix*((bg.^data).*((1-bg).^(1-data)));
    counts = params.bgMix*ones(size(data));
    
    samp_x = [];
    totalPost = 1;
    
    % -1 because last elem is bg model
    for (p=1:numel(qParts)-1)
        locs{p} = getLocs(imSize,params,p);
        [patches,patchCounts{p}] = getAppPatches(qParts,params,p);
        patchLikes{p} = getPatchLikes(patches,data,locs{p},patchCounts{p},params.partMix(p));
    end
    
    while(1)

        
        % Determine samples of previous state
        oldSamps = discretesample(totalPost,params.postParticles);
        
        %keep track of the unique samples of the previous brick states
        %we've drawn, and how many times we've drawn them
        uniqueOldSamp = unique(oldSamps);
        nOldSamp = zeros(numel(uniqueOldSamp),1);
        for (j=1:numel(uniqueOldSamp))
            nOldSamp(j) = sum(oldSamps==uniqueOldSamp(j) );
        end
        
        for (p=1:numel(qParts)-1)
            likeRatio = getLikeRatio(patchLikes{p},patchCounts{p},counts(:,:,uniqueOldSamp),like(:,:,uniqueOldSamp),locs{p});
            logLikeRatioPatch{p} = getLLRatioPatch(likeRatio,locs{p},imSize);
        end
        %logLikeRatioPatch: [imSize x nOrient]
        
        for (p=1:numel(qParts)-1)
            % saliencyScore: [imSize]
            saliencyScore(:,:,:,p) = getSaliencyScore(like(:,:,uniqueOldSamp),logLikeRatioPatch{p},nOldSamp,params);
        end
        [sc,ind] = max(saliencyScore(:));
        
        [y,x,thetaInd,partNum] = ind2sub(size(saliencyScore),ind);
        [y,x,thetaInd,partNum]
        
         [totalPost,samp_x,counts,like] = ...
             samplePosterior(params, partNum, ...
                             patchLikes, ...
                             patchCounts, ...
                             logLikeRatioPatch, ...
                             samp_x, ...
                             [y,x,thetaInd], ...
                             uniqueOldSamp, ...
                             nOldSamp, ...
                             totalPost, ...
                             counts,like,locs);
                
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
%         figure(2); viewSamples(samp_x,params.partSizes,imSize,totalPost,qParts);

    end

end


