function [res] = getLikeCell(likePxStruct,cellCentres,cellDims,params)
% Get (log)sum of log likelihoods in a specific cell: \int_cell P (I|pose)

    nTypes = numel(cellCentres);

    res = cell(nTypes,1);

    for (cellType=1:nTypes)
        centreUse = cellCentres{cellType};
        cellDimsUse = cellDims(cellType,:);

        boundPx = likePxStruct.boundaries{cellType};
        likes = likePxStruct.likes{cellType};
        counts = likePxStruct.counts{cellType};
        
        resType = zeros(size(centreUse,1),1);
        
        for (i=1:size(centreUse,1));
            id = find(getLikePxIdx(centreUse(i,:),cellDimsUse,boundPx,params) == 1);
            
            logCellLikes = log(0);
            for (j=1:numel(id))
                temp = log(likes{id(j)}./counts{id(j)});
                temp = sum(temp(:));

                logCellLikes = logsum([logCellLikes;temp]);
                
            end
            resType(i) = logCellLikes;
        end
        
        res{cellType} = resType;        
    end
end

