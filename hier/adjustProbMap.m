function [res,resNoAdjust] = adjustProbMap(allProbMapCells,slotType,ruleInd,slot,bricks,parentLocIdxs)
    % returns [#entries x size of parentLocIdxs]

    if (nargin < 6)
        resNoAdjust = allProbMapCells(ruleInd,slot,:);
    else
        resNoAdjust = allProbMapCells(ruleInd,slot,parentLocIdxs);
    end
    
    resNoAdjust = cell2mat(resNoAdjust);
    resNoAdjust = squeeze(resNoAdjust);
    
    res = resNoAdjust;


%     
%     % renormalize; cannot point to already active bricks
%     % ignore last brick; that's the one we're thinking of adding
%     res = resNoAdjust;
%     slots = find(getType(bricks(:,1:end-1)) == slotType);
%     slotsIdx = getLocIdx(bricks(:,1:end-1),slots);
%     res(slotsIdx,:) = 0;
%     res = bsxfun(@rdivide,res,sum(res,1));
%     
%     assert(~any(isnan(res(:))));
end