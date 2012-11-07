function [logPosteriorRatio] = getSaliencyScore(logLikeRatioPatch,nOldSamp,locs,imSize,params)
    % logLikeRatioPatch: [imSize,nOrientations, nOldSamp]
    nOldSamp = reshape(nOldSamp,[1,1,1,numel(nOldSamp)]);

    % [nOrientations,locs,nOldSample]
    logLikeRatioPatch = bsxfun(@plus,logLikeRatioPatch,log(nOldSamp));

    priorLoc = fspecial('gaussian',[2*round(3*params.brickStd)+1,2*round(3*params.brickStd)+1],params.brickStd);
    
    factor = max(logLikeRatioPatch,[],3);
    logLikeRatioPatch = bsxfun(@minus,logLikeRatioPatch,factor);
    
    logPosteriorRatio = bsxfun(@plus,log(convn(exp(logLikeRatioPatch),priorLoc,'same')),factor);
    logPosteriorRatio = logsum(logsum(logPosteriorRatio,4),3)-log(sum(nOldSamp));
end

