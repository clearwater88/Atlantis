function [logPosterior] = getSaliencyScore(likeOld,logLikeRatioPatch,nOldSamp,params)
    % logLikeRatioPatch: [imSize,nOrientations, nOldSamp]
    nOldSamp = reshape(nOldSamp,[1,1,1,numel(nOldSamp)]);

    % if we want it proper
    likeOld = squeeze(sum(sum(log(likeOld),1),2));
    likeOld = reshape(likeOld,[1,1,1,size(likeOld,1)]);
    logLikePatch = bsxfun(@plus,logLikeRatioPatch,likeOld);
    
    % [nOrientations,locs,nOldSample]
    logLikePatch = bsxfun(@plus,logLikePatch,log(nOldSamp));

    priorLoc = fspecial('gaussian',[2*round(3*params.brickStd)+1,2*round(3*params.brickStd)+1],params.brickStd);
    
    factor = max(logLikePatch,[],3);
    logLikePatch = bsxfun(@minus,logLikePatch,factor);
    
    logPosterior = bsxfun(@plus,log(convn(exp(logLikePatch),priorLoc,'same')),factor);
    logPosterior = logsum(logsum(logPosterior,4),3)-log(sum(nOldSamp));
end

