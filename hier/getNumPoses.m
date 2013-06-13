function [nPoses] = getNumPoses(cellParams,likePxStruct)

    nTypes = numel(cellParams.centres);
    nPoses = cell(nTypes,1);
    
    for (n=1:nTypes)
       centreType = cellParams.centres{n};
       nLoc = size(centreType,1);
       
       tempPoses = ones(nLoc,1);
       for (i=1:nLoc)
           ids = find(getLikePxIdx(centreType(i,:), ...
                                   cellParams.dims(n,:), ...
                                   likePxStruct.boundaries{n}) == 1);
           tempPoses(i) = numel(ids);
       end
        nPoses{n} = tempPoses;
    end
end

