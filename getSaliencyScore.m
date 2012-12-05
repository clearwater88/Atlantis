function [logPostRes] = getSaliencyScore(likeOld,logLikeRatioPatch,nOldSamp,params)
    % logLikeRatioPatch: [imSize,nOrientations, nOldSamp]
    % logPostRes: [imSize x nOrientUse]; already done uniform prior on
    %             orientation
    nOldSamp = reshape(nOldSamp,[1,1,1,numel(nOldSamp)]);

    % if we want the proper posterior
    likeOld = squeeze(sum(sum(log(likeOld),1),2));
    likeOld = reshape(likeOld,[1,1,1,size(likeOld,1)]);
    logLikePatch = bsxfun(@plus,logLikeRatioPatch,likeOld);
    
    % [imSize,nOrientations,nOldSample]
    logLikePatch = bsxfun(@plus,logLikePatch,log(nOldSamp));

    % implicit uniform prior on orientation
    priorLoc = fspecial('gaussian',[2*round(3*params.brickStd)+1,2*round(3*params.brickStd)+1],params.brickStd);
    
    factor = max(logLikePatch,[],3);
    logLikePatch = bsxfun(@minus,logLikePatch,factor);
    
    logPosterior = bsxfun(@plus,log(convn(exp(logLikePatch),priorLoc,'same')),factor);
    logPosterior = logsum(logPosterior,4)-log(sum(nOldSamp));
    
    nOrientSteps = 2*pi/params.orientPriorStep;
    logPostRes = zeros([size(logPosterior,1),size(logPosterior,2),nOrientSteps]);
    stepSize = floor(size(logPosterior,3)/nOrientSteps);
    
    % do uniform orientation prior now
    for (i=1:nOrientSteps)
        logPostTemp = logPosterior(:,:,(i-1)*stepSize+1:i*stepSize);
        logPostRes(:,:,i) = logsum(logPostTemp,3);
    end
    
end

