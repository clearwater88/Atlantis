function [res] = getLogLikeCellRatio(ratios,boundaries,cellParams)
% Get (log)sum of log likelihoods in a specific cell:
% \int_{pose in cell} P(pose | cell) * P(I|pose_0, pose)/P(I|pose_0)

    cellCentres = cellParams.centres;
    cellDims = cellParams.dims;

    nTypes = numel(cellCentres);

    res = cell(nTypes,1);

    for (cellType=1:nTypes)
        centreUse = cellCentres{cellType};
        cellDimsUse = cellDims(cellType,:);

        boundsType = boundaries{cellType};
        ratiosType = ratios{cellType};
        
        resType = zeros(size(centreUse,1),1);
        
        for (i=1:size(centreUse,1));
%             id = find(getLikePxIdx(centreUse(i,:),cellDimsUse,boundsType) == 1);
%             
%             a = zeros(numel(id),1);
%             for (j=1:numel(id))
%                 
%                 temp = ratiosType{id(j)};
%                 a(j) = sum(log(temp(:)));
%             end
% %             
            id = getLikePxIdx(centreUse(i,:),cellDimsUse,boundsType) == 1;
            
            b=ratiosType(id);
            c=cellfun(@log,b,'UniformOutput',0);
            c=cellfun(@sum,c,'UniformOutput',0);
            c=cellfun(@sum,c,'UniformOutput',0);
            a = cell2mat(c);

            
            logCellLikes = logsum(a);
            resType(i) = logCellLikes;
        end
        
        res{cellType} = resType;        
    end
end

