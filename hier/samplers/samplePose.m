function pose = samplePose(likeIm,countsIm,likePxStruct,cellType,centreIdx,cellCentres,cellDims,params)
    % need to provide particle

    cellCentre = cellCentres{cellType}(centreIdx,:);
    cellDim = cellDims(cellType,:);
    bound = likePxStruct.boundaries{cellType};
    likes = likePxStruct.likes{cellType};
    counts = likePxStruct.counts{cellType};
    poses = likePxStruct.poses{cellType};
    
    id = find(getLikePxIdx(cellCentre,cellDim,bound,params) == 1);
    
    logProbs = zeros(numel(id),1);
    for (i=1:numel(id))
        
        likeUse = likes{id(i)};
        countsUse = counts{id(i)};
        boundUse = bound(1:2,:,id(i)); % for projecting into image
        
        [likeUse,countsImUse] = projectIntoIm(likeIm,countsIm,likeUse,countsUse,boundUse);
        logProbs(i) = sum(log(likeUse(:)./countsImUse(:)));       
        
    end
    
    probs = exp(logProbs-logsum(logProbs));
    probs = probs/sum(probs); %MATLAB lacks precision, apparently.
    sampleId = id(mnrnd(1,probs')==1);
    pose = poses(sampleId,:)';
end

