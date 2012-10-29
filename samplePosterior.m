function [totalPost,samp_x,counts,like] = samplePosterior(params,patchLikes,patchCounts,countsOld,likeOld,totalPostOld,samp_xOld,brickCentre,locs)

    imSize = [size(countsOld,1),size(countsOld,2)];
    pSize = [size(patchCounts,1),size(patchCounts,2)];
    
    counts = zeros([size(countsOld,1),size(countsOld,2),params.postParticles]);
    like = zeros([size(likeOld,1),size(likeOld,2),params.postParticles]);
    totalPost = zeros(params.postParticles,1);
    
    % sample from old posterior
    samps = rand(params.postParticles,1);
    cumLikeOld = cumsum(totalPostOld);

    samp_x = zeros(params.postParticles,size(samp_xOld,2)+3);

    % draw from p(x_new | x_old,I)
    
    nOldSamps = numel(totalPostOld);
    newSampCache = cell(nOldSamps,1);
    
    % prior for location
    prior = params.brickOn*mvnpdf(locs,brickCentre,params.brickStd)';
    % special case for brick = off
    prior(end+1) = 1-params.brickOn;
    
    nOrient = numel(params.orientationsUse);
    nLocs = size(locs,1);
    
     for (i=1:params.postParticles)
        if(mod(i,100) == 0)
            display(sprintf('On %d / %d particles', i,params.postParticles));
        end
        
        oldSamp = find(cumLikeOld >= samps(i),1);
        likeOldUse = likeOld(:,:,oldSamp);
        countsOldUse = countsOld(:,:,oldSamp);
        totalPostOldUse = totalPostOld(oldSamp);
        
        % No posterior cache exists? Compute it, otherwise, load the
        % samples
        if(isempty(newSampCache{oldSamp}))
            
            likeRatio = getLikeRatio(patchLikes,patchCounts, ...
                                     countsOld(:,:,oldSamp), ...
                                     likeOld(:,:,oldSamp),locs);
            
            % nOrient x nLocs
            llRatio = squeeze(sum(sum(log(likeRatio),1),2));
            % logRatioJoint is up to a constant
            logRatioJoint = bsxfun(@plus,llRatio,log(prior(1:end-1)));
            logRatioJoint = logRatioJoint(:);          
            logRatioJoint(end+1) = log(1)+log(prior(end));
            
            newSampCache{oldSamp}.posterior = ...
                exp(logRatioJoint - logsum(logRatioJoint,1));
            
        end
        posterior = newSampCache{oldSamp}.posterior;

        % NOW DRAW FROM POSTERIOR
        cumTotalLikePost = cumsum(posterior);
        postSamp = find(cumTotalLikePost >= rand(1,1),1);
        
        % is it special 'off' particle?
        if (postSamp == size(posterior,1))
            samp_xPost = params.sampOffFlag*ones(3,1);
            like(:,:,i) = likeOldUse;
            counts(:,:,i) = countsOldUse;
            totalPost(i) = totalPostOldUse;
        else
            [orientNum,locNum] = ind2sub([nOrient,nLocs],postSamp);
            centre = locs(locNum,:);
            samp_xPost(1:2) = centre;
            samp_xPost(3) = params.orientationsUse(orientNum);
            
            likePatchUse = patchLikes(:,:,orientNum,locNum);
            countsPatchUse = patchCounts(:,:,orientNum);
            
            yStart = centre(1) - (pSize(1)-1)/2;
            xStart = centre(2) - (pSize(2)-1)/2;
            
            likePost = likeOldUse;
            likePost(yStart:yStart+pSize(1)-1,xStart:xStart+pSize(1)-1) = ...
                likePost(yStart:yStart+pSize(2)-1,xStart:xStart+pSize(2)-1) + likePatchUse;
            like(:,:,i) = likePost;
            
            countsPost = countsOldUse;
            countsPost(yStart:yStart+pSize(1)-1,xStart:xStart+pSize(1)-1) = ...
                countsPost(yStart:yStart+pSize(2)-1,xStart:xStart+pSize(2)-1)+countsPatchUse;
            counts(:,:,i) = countsPost;
            
            totalPost(i) = posterior(postSamp);
        end
        
        if (isempty(samp_xOld))
            samp_x(i,:) = samp_xPost;
        else
            samp_x(i,1:end-3) = samp_xOld(oldSamp,:);
            samp_x(i,end-2:end) = samp_xPost;
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

