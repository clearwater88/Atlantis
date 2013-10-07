function [logProbCell] = getLogLikeCellRatio(ratios,cellParams,likePxIdxCells,dirtyRegion,nPosesCell,logLikeCellOld,templateSizes)
% Get sum of log likelihoods in a specific cell:
% (\int_{pose in cell} P(pose | cell) * P(I|pose_0, pose))/P(I|pose_0)

    nTypes = cellParams.nTypes;
    logProbCell = cell(nTypes,1);

    for (n=1:nTypes)
        likePxIdxCellsUse = likePxIdxCells{n};
        
        ratiosType = ratios{n};
        nElem = size(likePxIdxCellsUse,1);
        maxSz= (max(templateSizes(n,:))+1)/2;
        
        if(~isempty(dirtyRegion))
            cb=cellParams.centreBoundaries{n};
            cb(1:2,1,:) = cb(1:2,1,:) - maxSz;
            cb(1:2,2,:) = cb(1:2,2,:) + maxSz;
            
            regionIntersect = doesIntersect(dirtyRegion,cb);
            oldLogCellProbUse = logLikeCellOld{n};
        else
            regionIntersect = ones(size(cellParams.centreBoundaries{n},3),1);
        end
        dirty = find(regionIntersect==1);
        
        logProbCellTemp = zeros(nElem,1);
        %logProbCellTemp2 = zeros(nElem,1);
        if(~isempty(dirtyRegion)) % if have dirtyRegion, then have oldLogCellProbUse
            logProbCellTemp(regionIntersect==0) = oldLogCellProbUse(regionIntersect==0);
        end
        
        for (j=1:numel(dirty))
            i= dirty(j);
            id = likePxIdxCellsUse{i};
            if(~isempty(ratiosType(id)))
                logProbCellTemp(i) = logsum(ratiosType(id),1) - log(nPosesCell{n}(i));  % add in prior over poses
            else
                logProbCellTemp(i) = -Inf;
            end
        end
        logProbCell{n} = logProbCellTemp;        
        
%         for (i=1:numel(regionIntersect))
%             id = likePxIdxCellsUse{i};
%             if(~isempty(ratiosType(id)))
%                 logProbCellTemp2(i) = logsum(ratiosType(id),1) - log(nPosesCell{n}(i));  % add in prior over poses
%             else
%                 logProbCellTemp2(i) = -Inf;
%             end
%         end
%         
%         diff = abs(logProbCellTemp-logProbCellTemp2);
%         assert(max(diff(:)) <0.0001);
        
        
    end
end

