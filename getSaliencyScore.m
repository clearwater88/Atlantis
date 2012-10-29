function [res] = getSaliencyScore(likeRatio,nSalSamp,params)
    % likeRatio: [patchSize, nOrientations, nLocs, nOldSamp]
    nSalSamp = reshape(nSalSamp,[1,1,1,1,numel(nSalSamp)]);
    
    %jointRatio = likeRatio*params.brickOn;
    res = sum(sum(log(likeRatio),1),2);
    res = bsxfun(@plus,res,log(nSalSamp));
    res = squeeze(logsum(logsum(res,3),5))-log(sum(nSalSamp));
end

