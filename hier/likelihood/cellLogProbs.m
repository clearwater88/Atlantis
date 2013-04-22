function [logProbs] = cellLogProbs(ids,likeIm,countsIm,likes,counts,bound)
    % log probs of each legal configuration in cell

    logProbs = zeros(numel(ids),1);
    for (i=1:numel(ids))
        
        likeUse = likes{ids(i)};
        countsUse = counts{ids(i)};
        boundUse = bound(1:2,:,ids(i)); % for projecting into image
        
        [likeUse,countsImUse] = projectIntoIm(likeIm,countsIm,likeUse,countsUse,boundUse);
        logProbs(i) = sum(log(likeUse(:)./countsImUse(:)));       
    end
end

