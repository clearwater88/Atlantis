function [totalLike,samp_x,countMask,likeIm] = samplePosterior(params,data,qParts,partSize,loc,totalLikeOld,samp_xOld,countMaskOld,likeImOld)

    bg = qParts{end};
    
    if(isempty(totalLikeOld))
        likeBg = (bg.^data).*((1-bg).^(1-data));
        countMaskBg = zeros(size(data));
        [totalLike,samp_x,countMask,likeIm] = samplePosteriorX(params,data,qParts,partSize,loc,likeBg,params.postParticles,countMaskBg);
        return;
    end
    % sample from old posterior
    samps = rand(params.postParticles,1);
    cumLikeOld = cumsum(totalLikeOld);
    
    totalLike = zeros(params.

    for (i=1:params.postParticles)
       oldSamp = find(cumLikeOld >= samps(i),1);
       
       countMaskUse = countMaskOld(:,:,oldSamp);
       likeImUse = likeImOld(:,:,oldSamp);
       
       [totalLikePost,samp_xPost,countMaskPost,likeImPost] = samplePosteriorX(params,data,qParts,partSize,loc,likeImUse,params.postXSamples,countMaskUse);
       
       % NOW DRAW FROM THIS POSTERIOR
       cumTotalLike = cumsum(totalLike);
       curSamp = find(cumTotalLike >= rand(1,1),1);
       
       
    end
    

end

