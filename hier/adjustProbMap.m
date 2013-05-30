function res = adjustProbMap(allProbMapCells,ruleInd,slot,bricks,parentLocIdxs)
    % returns [#entries x size of parentLocIdxs]
    
    if (nargin < 5)
        res = allProbMapCells(ruleInd,slot,:);
    else
        res = allProbMapCells(ruleInd,slot,parentLocIdxs);
    end
    res = cell2mat(res);
    res = squeeze(res);
end