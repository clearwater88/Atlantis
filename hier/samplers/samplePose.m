function [pose,poseOffset] = samplePose(cellType,centreIdx,cellCentres,cellDims,boundariesPx,likePx,countsPx)

    cellCentre = cellCentres{cellType}(centreIdx,:);
    cellDim = cellDims(cellType,:);
    boundary = boundariesPx{cellType};
    likes = likePx{cellType};

    id = getLikePxIdx(cellCentre,cellDim,boundary);
    
    probs = likes.*id;
    probs = probs/sum(probs);
    
end

