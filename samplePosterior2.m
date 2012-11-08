function [totalPost,samp_x,counts,like] = samplePosterior2(params,patchLikes,patchCounts,llrPatch,samp_xOld,brickCentre,uniqueOldSamp,nOldSamp,totalPostOld,countsOld,likeOld,locsOrig)
    %logLikeRatioPatch: [imSize,nOrient,nSamp]
    
    samp_x = zeros(sum(nOldSamp),size(samp_xOld,2)+3);
    counts = zeros([size(countsOld,1),size(countsOld,2),params.postParticles]);
    like = zeros([size(likeOld,1),size(likeOld,2),params.postParticles]);
    totalPost = zeros(sum(nOldSamp),1);
    
    imSize = [size(llrPatch,1),size(llrPatch,2)];
    pSize = [size(patchCounts,1),size(patchCounts,2)];
    nOrient = numel(params.orientationsUse);
    
    % llrPatch: [prod(imSize),#orient,#oldSamples]
    llrPatch = reshape(llrPatch,[prod(imSize),size(llrPatch,3),size(llrPatch,4)]);
    locs = imSize(1)*(locsOrig(:,2)-1)+locsOrig(:,1);

    % uniform on orientation
    pts = meshgridRaster(1:imSize(1),1:imSize(2));
    prior = params.brickOn*mvnpdf(pts,brickCentre,[params.brickStd,params.brickStd]);
    
    
    ljointrPatch = bsxfun(@plus,llrPatch,log(prior));    
    ljointrPatch = reshape(ljointrPatch,[size(ljointrPatch,1)*size(ljointrPatch,2),size(ljointrPatch,3),size(ljointrPatch,4)]);
    
    %don't need likelihood ratio term, because it's 1: comparing to off
    %brick is comparing to what's in the background already
    ljointrPatch(end+1,:) = log(1-params.brickOn);
     % ljointrPatch: [prod(imSize)*#orient+1,#oldSamples]
    
    % lPosterior: [prod(imSize)*#orient+1,#oldSamples]
    lPosterior = exp(bsxfun(@minus,ljointrPatch, logsum(ljointrPatch,1)));
    
    sampCount = 1;
    for (i=1:numel(uniqueOldSamp))
        oldSamp = uniqueOldSamp(i);
        lPosteriorUse = lPosterior(:,i);
        likeOldUse = likeOld(:,:,oldSamp);
        countsOldUse = countsOld(:,:,oldSamp);
        totalPostOldUse = totalPostOld(oldSamp);
        
        for (j=1:nOldSamp(i))
            postSamp = find(cumsum(lPosteriorUse) >= rand(1,1),1);

            % off state?
            if(postSamp == size(lPosteriorUse,1))
                samp_xPost = params.sampOffFlag*ones(3,1);
                like(:,:,sampCount) = likeOldUse;
                counts(:,:,sampCount) = countsOldUse;
                totalPost(sampCount) = totalPostOldUse;
            
            else
                [loc,orientNum] = ind2sub([prod(imSize),nOrient],postSamp);
                [y,x] = ind2sub(imSize,loc);
                samp_xPost(1:2) = [y,x];
                samp_xPost(3) = params.orientationsUse(orientNum);
                
                locNum = find(locs==loc,1,'first');

                likePatchUse = patchLikes(:,:,orientNum,locNum);
                countsPatchUse = patchCounts(:,:,orientNum);
                likePostSamp = likeOldUse;
                                
                yStart = y - (pSize(1)-1)/2;
                xStart = x - (pSize(2)-1)/2;
                likePostSamp(yStart:yStart+pSize(1)-1,xStart:xStart+pSize(1)-1) = ...
                    likePostSamp(yStart:yStart+pSize(2)-1,xStart:xStart+pSize(2)-1) + likePatchUse;
                like(:,:,sampCount) = likePostSamp;
                
                countsPostSamp = countsOldUse;
                countsPostSamp(yStart:yStart+pSize(1)-1,xStart:xStart+pSize(1)-1) = ...
                    countsPostSamp(yStart:yStart+pSize(2)-1,xStart:xStart+pSize(2)-1)+countsPatchUse;
                counts(:,:,sampCount) = countsPostSamp;
            
                totalPost(sampCount) = lPosteriorUse(postSamp);
            end
            
            if (isempty(samp_xOld))
                samp_x(sampCount,:) = samp_xPost;
            else
                samp_x(sampCount,1:end-3) = samp_xOld(oldSamp,:);
                samp_x(sampCount,end-2:end) = samp_xPost;
            end
            
            sampCount = sampCount+1;
        end
    end
    totalPost = totalPost/sum(totalPost);
    %%% Now collapse particle representation
    [samp_xF] = unique(samp_x,'rows');
    
    nUnique = size(samp_xF,1);
    
    totalPostF = zeros(nUnique,1);
    countsF = zeros([size(counts,1),size(counts,2),nUnique]);
    likeF = zeros([size(like,1),size(like,2),nUnique]);
    
    for (i=1:size(samp_xF,1))
        mems = (ismember(samp_x,samp_xF(i,:),'rows'));
        id = find(mems,1,'first');
        nId = sum(mems);
        
        countsF(:,:,i) = counts(:,:,id);
        likeF(:,:,i) = like(:,:,id);
        totalPostF(i) = totalPost(id)*nId;
    end
    totalPost = totalPostF;
    counts = countsF;
    like = likeF;
    samp_x = samp_xF;
    %%% Now collapse particle representation
end

