function [pose,likeNew,countNew] = samplePose(likeIm,countsIm,likePxStruct,likePxIdxCell,cellType,centreIdx)

    % need to provide particle
    % also updates likelihood maps

    poses = likePxStruct.poses{cellType};
    
    ids = find(likePxIdxCell(:,centreIdx) == 1);
    
    [logProbs,likesNew,countsNew] = ...
        cellLogProbs(ids,likeIm,countsIm, ...
                     likePxStruct.likes{cellType}, ...
                     likePxStruct.counts{cellType}, ...
                     likePxStruct.bounds{cellType});
     
    probs = exp(logProbs-logsum(logProbs));
    probs = probs/sum(probs); %MATLAB lacks precision, apparently.
    sampleId = mnrnd(1,probs')==1;
    pose = poses(ids(sampleId),:)';
    likeNew = likesNew{sampleId};
    countNew = countsNew{sampleId};
    
end

