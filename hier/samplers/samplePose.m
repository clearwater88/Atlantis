function [pose,likeNew,countNew] = samplePose(likeIm,countsIm,likePxStruct,likePxIdxCell,cellType,centreIdx)

    % need to provide particle
    % also updates likelihood maps

    poses = likePxStruct.poses{cellType};
    
    ids = likePxIdxCell{centreIdx};
    
    likes = likePxStruct.likes{cellType};
    counts = likePxStruct.counts{cellType};
    bounds = likePxStruct.bounds{cellType};
    
    logProbs = cellLogProbs(ids,likeIm,countsIm, likes, counts, bounds);
     
    probs = exp(logProbs-logsum(logProbs));
    probs = probs/sum(probs); %MATLAB lacks precision, apparently.
    sampleId = mnrnd(1,probs')==1;
    pose = poses(ids(sampleId),:)';
    
    likeUse = likes{ids(sampleId)};
    countsUse = counts{ids(sampleId)};
    boundUse = bounds(1:2,:,ids(sampleId)); % for projecting into image
        
    [likeNew,countNew] = projectIntoIm(likeIm,countsIm,likeUse,countsUse,boundUse);
end

