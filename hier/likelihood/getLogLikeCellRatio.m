function [logProbCell] = getLogLikeCellRatio(ratios,cellParams,likePxIdxCells,dirtyRegion,nPosesCell,logLikeCellOld)
% Get sum of log likelihoods in a specific cell:
% (\int_{pose in cell} P(pose | cell) * P(I|pose_0, pose))/P(I|pose_0)

    nTypes = cellParams.nTypes;
    logProbCell = cell(nTypes,1);

    for (n=1:nTypes)
        likePxIdxCellsUse = likePxIdxCells{n};
        
        ratiosType = ratios{n};
        nElem = size(likePxIdxCellsUse,2);
        
        if(~isempty(dirtyRegion))
            regionIntersect = doesIntersect(dirtyRegion,cellParams.centreBoundaries{n});
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
            id = likePxIdxCellsUse(:,i) == 1;
            
%             if(regionIntersect(i) == 0)
%                logProbCellTemp(i) = oldLogCellProbUse(i); 
%                continue;
%                %logProbCellTemp2(i) = oldLogCellProbUse(i);
%             end
            
%             b=ratiosType(id);
%             c=cellfun(@log,b,'UniformOutput',0);
%             c=cellfun(@sum,c,'UniformOutput',0);
%             c=cellfun(@sum,c,'UniformOutput',0);

            c=ratiosType(id);

            logProbCellTemp(i) = logsum(cell2mat(c),1) - log(nPosesCell{n}(i));  % add in prior over poses
        end
        logProbCell{n} = logProbCellTemp;        
    end
end

