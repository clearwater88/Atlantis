function [probMap] = adjustProbMap(probMap,inds,type,bricks)
    % cut off very end; active brick we're considering
    idx = find(getType(bricks(:,1:end-1))==type);
    locIdx = getLocIdx(bricks,idx);
    probMap(locIdx) = 0;
    probMap(inds) = probMap(inds)/sum(probMap(inds));
end