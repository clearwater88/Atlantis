function pose = samplePose(likeIm,countsIm,likePxStruct,cellType,centreIdx,cellParams)
    % need to provide particle

    cellCentre = cellParams.centres{cellType}(centreIdx,:);
    cellDim = cellParams.dims(cellType,:);
    bound = likePxStruct.boundaries{cellType};
    likes = likePxStruct.likes{cellType};
    counts = likePxStruct.counts{cellType};
    poses = likePxStruct.poses{cellType};
    
    ids = find(getLikePxIdx(cellCentre,cellDim,bound) == 1);
    
    [logProbs] = cellLogProbs(ids,likeIm,countsIm,likes,counts,bound);
     
    probs = exp(logProbs-logsum(logProbs));
    probs = probs/sum(probs); %MATLAB lacks precision, apparently.
    sampleId = ids(mnrnd(1,probs')==1);
    pose = poses(sampleId,:)';
end

