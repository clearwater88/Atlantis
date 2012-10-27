function [res] = getSaliencyScore(likeRatio)
    % likeRatio: [patchSize, nOrientations, nLocs, nOldSamp]
    res = (sum(sum(log(likeRatio),1),2));
    res = squeeze(logsum(logsum(res,3),5));
end

