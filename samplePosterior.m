function [totalLike,samp_x,counts,likeFg] = samplePosterior(params,data,qParts,partSize,loc,totalLikeOld,likeFgOld,samp_xOld,countsOld)

    bg = qParts{end};
    likeBg = (bg.^data).*((1-bg).^(1-data));
    
    if(isempty(likeFgOld))
        counts = zeros(size(data));
        likeFg = zeros(size(data));
        [totalLike,samp_x,counts,likeFg] = samplePosteriorX(params,data,qParts,partSize,loc,likeFg,likeBg,params.postParticles,counts);
        return;
    end
    % sample from old posterior
    samps = rand(params.postParticles,1);
    cumLikeOld = cumsum(totalLikeOld);

    samp_x = zeros(params.postParticles,size(samp_xOld,2)+3);
    
    counts = zeros([size(data),params.postParticles]);
    likeFg = zeros([size(data),params.postParticles]);
    totalLike = zeros(params.postParticles,1);
    % draw from p(x_new | x_old,I)
    for (i=1:params.postParticles)
        if(mod(i,100) == 0)
            display(sprintf('On %d / %d particles', i,params.postParticles));
        end
        
       oldSamp = find(cumLikeOld >= samps(i),1);
       
       countsOldUse = countsOld(:,:,oldSamp);
       likeFgOldUse = likeFgOld(:,:,oldSamp);
       [totalLikePost,samp_xPost,countsPost,likeFgPost] = samplePosteriorX(params,data,qParts,partSize,loc,likeFgOldUse,likeBg,params.postXSamples,countsOldUse);
       
       % NOW DRAW FROM POSTERIOR
       cumTotalLikePost = cumsum(totalLikePost);
       postSamp = find(cumTotalLikePost >= rand(1,1),1);
       
       samp_x(i,1:end-3) = samp_xOld(oldSamp,:);
       samp_x(i,end-2:end) = samp_xPost(postSamp,:);
       counts(:,:,i) = countsPost(:,:,postSamp);
       likeFg(:,:,i) = likeFgPost(:,:,postSamp);
       totalLike(i) = totalLikePost(postSamp);
    end
    totalLike = totalLike/sum(totalLike);
end

