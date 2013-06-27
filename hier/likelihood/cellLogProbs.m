function [logProbs,likesNew,countsNew] = cellLogProbs(ids,likeIm,countsIm,likes,counts,bounds)
    % log probs of each legal configuration in cell. logProb of ENTIRE
    % image

    logProbs = zeros(numel(ids),1);
    likesNew = cell(numel(ids),1);
    countsNew = cell(numel(ids),1);
    
    defaultLikeIm = sum(log(likeIm(:)./countsIm(:)));
    for (i=1:numel(ids))
        
        likeUse = likes{ids(i)};
        countsUse = counts{ids(i)};
        boundUse = bounds(1:2,:,ids(i)); % for projecting into image
        
        [likeUse,countsImUse] = projectIntoIm(likeIm,countsIm,likeUse,countsUse,boundUse);
        
        likesTemp = likeUse(boundUse(1,1):boundUse(1,2),boundUse(2,1):boundUse(2,2));
        countsTemp = countsImUse(boundUse(1,1):boundUse(1,2),boundUse(2,1):boundUse(2,2));

        initLikes = likeIm(boundUse(1,1):boundUse(1,2),boundUse(2,1):boundUse(2,2));
        initCounts = countsIm(boundUse(1,1):boundUse(1,2),boundUse(2,1):boundUse(2,2));

        logProbs(i) = sum(log(likesTemp(:)./countsTemp(:))) - ...
                      sum(log(initLikes(:)./initCounts(:)));
    end
    logProbs=logProbs+defaultLikeIm;
end

