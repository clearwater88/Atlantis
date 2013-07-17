function [cellPoses] = getCellPoses(posesStruct, cellParams)
    tic
    nTemplates = numel(posesStruct.rotTemplate);
    cellPoses = cell(nTemplates,1);
    
    for (i=1:nTemplates)
        centreBoundaries = cellParams.centreBoundaries{i};
        cellPosesTemp = cell(size(centreBoundaries,3),1);
        for (j=1:nTemplates)
            bounds=posesStruct.bounds{j};
            
            for (k=1:size(cellPosesTemp,1))
                cellPosesTemp{k} = find(doesIntersect(centreBoundaries(1:2,1:2,k),bounds)==1);
            end
        end
        cellPoses{i} = cellPosesTemp;
    end
    toc
end

