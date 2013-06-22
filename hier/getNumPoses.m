function [nPoses] = getNumPoses(likePxIdxCells)

    nTypes = numel(likePxIdxCells);
    nPoses = cell(nTypes,1);
    
    for (n=1:nTypes)
        nPoses{n} = sum(likePxIdxCells{n},1)';
    end
end

