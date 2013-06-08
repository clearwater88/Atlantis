function [saliencyMaps,logProbOptions] = computeSaliencyMap(defaultLogLikeIm,logProbCellsRatio,logPsumGNoPoints,logPsumGs,childMessages,nBricksOnSelfRoots,particleProbs,cellParams,params)

    saliencyMaps = cell(cellParams.nTypes,1);
    for(n=1:cellParams.nTypes)
        saliencyMaps{n} = zeros(size(cellParams.centres{n},1),1);
    end

    %3 options: off, on/self root, on/with parent
    logProbOptions = cell(numel(particleProbs),1);
    for (i=1:numel(particleProbs))
        logProbOptions{i} = cell(cellParams.nTypes,1);
        for(n=1:cellParams.nTypes)
            logProbOptions{i}{n} = zeros(size(cellParams.centres{n},1),3); % 3 options
        end
    end

    for (i=1:numel(particleProbs))
        for(n=1:cellParams.nTypes)
            % incorporate image evidence/self rooting stuff
            logProbOptions{i}{n}(:,1) = logProbOptions{i}{n}(:,1) + defaultLogLikeIm(i) + log(1-params.probRoot);
            logProbOptions{i}{n}(:,2) = logProbOptions{i}{n}(:,2) + defaultLogLikeIm(i) + logProbCellsRatio{i}{n} + log(params.probRoot);
            logProbOptions{i}{n}(:,3) = logProbOptions{i}{n}(:,3) + defaultLogLikeIm(i) + logProbCellsRatio{i}{n};
            
            logPsumGNoPointsUse = sum(logPsumGNoPoints{i}{n},2);
            logA= sum(logPsumGs{i});
            logB= logPsumGNoPointsUse;
            % incorproate top-down messages
            logDiff = log(exp(logA-logB)-1) + logB;
            logProbOptions{i}{n}(:,1) = logProbOptions{i}{n}(:,1) + logPsumGNoPointsUse;
            logProbOptions{i}{n}(:,2) = logProbOptions{i}{n}(:,2) + logPsumGNoPointsUse;
            logProbOptions{i}{n}(:,3) = logProbOptions{i}{n}(:,3) + logDiff;
            
            % incorproate bottom-up messages
            logProbOptions{i}{n}(:,1) = logProbOptions{i}{n}(:,1) + nBricksOnSelfRoots(i)*log(params.probRoot);
            logProbOptions{i}{n}(:,2) = logProbOptions{i}{n}(:,2) + childMessages{i}{n};
            logProbOptions{i}{n}(:,3) = logProbOptions{i}{n}(:,3) + childMessages{i}{n};
             
            saliencyMaps{n} = logsum(logProbOptions{i}{n}(:,2:3),2) + log(particleProbs(i));
             
        end
    end   
end

