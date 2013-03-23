function [likeSingle] = computeLike(data,qParts,imPtsInd,qInd)
    % likeSingle = 0 also used to mean undefined. Because we're just using these for
    % sums

    likeSingle = zeros(size(data));
    dataUse = data(imPtsInd);    
    likeSingle(imPtsInd) = (qParts(qInd).^dataUse).*(1-qParts(qInd)).^(1-dataUse);
end

