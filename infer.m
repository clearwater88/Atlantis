function [totalPost,samp_x,counts,like] = infer(data,qParts,params)

    imSize = size(data);

    bg = qParts{end};

    % Initialize background model mixture component    
    like = params.bgMix*((bg.^data).*((1-bg).^(1-data)));
    counts = params.bgMix*ones(size(data));
    
    samp_x = [];
    totalPost = 1;
    
    % -1 for bg model
    for (p=1:numel(qParts)-1)
        locs{p} = getBrickLoc(imSize,params.partSizes);
        [patches,patchCounts{p}] = getAppPatches(qParts,params,p);
        patchLikes{p} = getPatchLikes(params,patches,data,locs{p},patchCounts{p},params.partMix(p));
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
        
        for (i=1:numel(qParts)-1)
            % saliencyScore: [imSize]
            saliencyScore(:,:,i) = getSaliencyScore(like(:,:,uniqueOldSamp),logLikeRatioPatch{i},nOldSamp,params);
        end
        [sc,i] = max(saliencyScore(:));

%         figure(1); imagesc(data); colormap(gray);
%         figure(2); imagesc(saliencyScore); colormap(gray);
%         pause(0.5);
        
        [y,x,partNum] = ind2sub(size(saliencyScore),i);
        sc
        [y,x,partNum]
        
         [totalPost,samp_x,counts,like] = ...
             samplePosterior2(params, partNum, ...
                              patchLikes, ...
                              patchCounts, ...
                              logLikeRatioPatch, ...
                              samp_x, ...
                              [y,x], ...
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
    
        %figure(2); viewSamples(samp_x,params.partSizes,imSize,totalPost,qParts);

    end

end


