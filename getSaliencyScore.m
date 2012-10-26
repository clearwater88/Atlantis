function [res] = getSaliencyScore(likeRatio)
    % likeRatio: [patchSize, nOrientations, nLocs]
    res = squeeze(sum(sum(log(likeRatio),1),2));
    res = squeeze(logsum(res,1));
end

