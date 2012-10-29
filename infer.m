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
        
        salSamp = discretesample(totalPost,params.salientSample);
        uniqueSalSamp = unique(salSamp);
        nSalSamp = zeros(numel(uniqueSalSamp),1);
        for (j=1:numel(uniqueSalSamp))
            nSalSamp(j) = sum(uniqueSalSamp(j) == salSamp);
        end
        
        likeRatio = getLikeRatio(patchLikes,patchCounts,counts(:,:,uniqueSalSamp),like(:,:,uniqueSalSamp),locs);
        saliencyScore = getSaliencyScore(likeRatio,nSalSamp,params);
        [sc,i] = max(saliencyScore);
        sc
        
        [totalPost,samp_x,counts,like] = ...
            samplePosterior(params,patchLikes,patchCounts,counts,like,totalPost,samp_x,locs(i,:),locs);
        nSamps = nSamps+1;
        
        sampOn = find(samp_x(:,end) ~= params.sampOffFlag);
        probOn = sum(totalPost(sampOn));
        probOn
        
        if (probOn < params.probOnThresh)
            break
        else
            nOn = sum(samp_x(:,end) ~= params.sampOffFlag);
            display(sprintf('Particles made on: %d/%d', nOn,size(samp_x,1)));
        end
        
%         
%         figure(100);
%         imshow(data);
%     
%         figure(2); viewSamples(samp_x,params.partSizes,imSize,totalPost);

    end

end


