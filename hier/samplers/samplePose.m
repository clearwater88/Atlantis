function [pose,likeNew,countNew] = samplePose(data,likeIm,countsIm,ratiosImCell,likePxIdxCells,posesStruct,cellType,centreIdx,mix)

    % need to provide particle
    % also updates likelihood maps

    poses = posesStruct.poses{cellType};
    ratiosIm = ratiosImCell{cellType};
    
    ids = likePxIdxCells{cellType}{centreIdx};
    
%     likes = likePxStruct.likes{cellType};
%     counts = likePxStruct.counts{cellType};
%     bounds = likePxStruct.bounds{cellType};
    
%     logProbs = cellLogProbs(ids,likeIm,countsIm, likes, counts, bounds);
     
    logProbs = ratiosIm(ids);

    probs = exp(logProbs-logsum(logProbs));
    probs = probs/sum(probs); %MATLAB lacks precision, apparently.
    sampleId = mnrnd(1,probs')==1;
    poseId = ids(sampleId);
    pose = poses(poseId,:)';
    
    [~,agInd] = min(abs(posesStruct.angles-pose(3)));
    
    template = posesStruct.rotTemplate{cellType}{agInd};
    boundUse = posesStruct.bounds{cellType}(:,:,poseId);
    countsUse = posesStruct.counts{cellType}{agInd};
    
    mask=posesStruct.mask{cellType}{agInd};
    
    % for projecting into image
    dataUse = data(boundUse(1,1):boundUse(1,2),boundUse(2,1):boundUse(2,2));
    likeUse = evalLikePixels(template,dataUse,mask,mix(cellType));
    
    [likeNew,countNew] = projectIntoIm(likeIm,countsIm,likeUse,countsUse,boundUse);
end

