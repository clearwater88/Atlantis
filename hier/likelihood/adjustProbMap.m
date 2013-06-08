function [resAdjust,resNoAdjust] = adjustProbMap(allProbMapCells,slotType,ruleInd,slot,bricks,parentLocIdxs)
    % returns [#entries x size of parentLocIdxs]

    if (nargin < 6)
        resNoAdjust = allProbMapCells(ruleInd,slot,:);
    else
        resNoAdjust = allProbMapCells(ruleInd,slot,parentLocIdxs);
    end
    
    resNoAdjust = cell2mat(resNoAdjust);
    resNoAdjust = squeeze(resNoAdjust);

    % renormalize; cannot point to already active bricks
    % ignore last brick; that's the one we're thinking of adding
    resAdjust = resNoAdjust;
    slots = find(getType(bricks(:,1:end-1)) == slotType);
    slotsIdx = getLocIdx(bricks(:,1:end-1),slots);
    resAdjust(slotsIdx,:) = 0;
    resAdjust = bsxfun(@rdivide,resAdjust,sum(resAdjust,1));
    
    assert(~any(isnan(resAdjust(:))));
end