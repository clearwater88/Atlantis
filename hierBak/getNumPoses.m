function [nPoses] = getNumPoses(likePxIdxCells)

    nTypes = numel(likePxIdxCells);
    nPoses = cell(nTypes,1);
    
    for (n=1:nTypes)
        temp = likePxIdxCells{n};
        %nPoses{n} = sum(likePxIdxCells{n},1)';
        nPoses{n} = cellfun(@numel,temp);
        
    end
end

