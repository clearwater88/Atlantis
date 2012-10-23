function [totalLike,samp_x,counts,like] = samplePosterior(params,data,qParts,partSize,loc,totalLikeOld,likeOld,samp_xOld,countsOld)

    % sample from old posterior
    samps = rand(params.postParticles,1);
    cumLikeOld = cumsum(totalLikeOld);

    samp_x = zeros(params.postParticles,size(samp_xOld,2)+3);
    
    counts = zeros([size(data),params.postParticles]);
    like = zeros([size(data),params.postParticles]);
    totalLike = zeros(params.postParticles,1);
    % draw from p(x_new | x_old,I)
    
    nOldSamps = numel(totalLikeOld);
    newSampCache = cell(nOldSamps,1);
    
    for (i=1:params.postParticles)
        if(mod(i,100) == 0)
            display(sprintf('On %d / %d particles', i,params.postParticles));
        end
        
        oldSamp = find(cumLikeOld >= samps(i),1);
        
        % No posterior cache exists? Compute it, otherwise, load the
        % samples
        if(isempty(newSampCache{oldSamp}))
            countsOldUse = countsOld(:,:,oldSamp);
            likeOldUse = likeOld(:,:,oldSamp);
            [totalLikePost,samp_xPost,countsPost,likePost] = samplePosteriorX(params,data,qParts,partSize,loc,likeOldUse,params.postXSamples,countsOldUse);
            newSampCache{oldSamp}.totalLikePost = totalLikePost;
            newSampCache{oldSamp}.samp_xPost = samp_xPost;
            newSampCache{oldSamp}.countsPost = countsPost;
            newSampCache{oldSamp}.likePost = likePost;
        else
            totalLikePost = newSampCache{oldSamp}.totalLikePost;
            samp_xPost = newSampCache{oldSamp}.samp_xPost;
            countsPost = newSampCache{oldSamp}.countsPost;
            likePost = newSampCache{oldSamp}.likePost;  
        end
       % NOW DRAW FROM POSTERIOR
       cumTotalLikePost = cumsum(totalLikePost);
       postSamp = find(cumTotalLikePost >= rand(1,1),1);
       
       if (isempty(samp_xOld))
          samp_x(i,:) = samp_xPost(postSamp,:);
       else
           samp_x(i,1:end-3) = samp_xOld(oldSamp,:);
           samp_x(i,end-2:end) = samp_xPost(postSamp,:);
       end

       counts(:,:,i) = countsPost(:,:,postSamp);
       like(:,:,i) = likePost(:,:,postSamp);
       totalLike(i) = totalLikePost(postSamp);

    end
    totalLike = totalLike/sum(totalLike);
end

