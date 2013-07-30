function sampleParticlesBP(data,posesStruct,likePxIdxCells,cellMapStruct,cellParams,params,ruleStruct,templateStruct)

    [likeTemp,countsTemp] = initLike(data,templateStruct);
    particles{1} = [];
    particleProbs  = 1;
    
    likesIm{1} = likeTemp;
    countsIm{1} = countsTemp;
    
    allParticles = {};
    allParticleProbs = {};

    % initialize
    brickIdx = 1;
    dirtyRegion = [];
    ratiosIm = cell(params.nParticles,1);
    logLikeCell = cell(params.nParticles,1);
    nPosesCell = getNumPoses(likePxIdxCells);
    
    while(1)
        % evaluate data term
        [logProbCellRatioOldParticle,ratiosImOldParticle,defaultLogLikeIm] = evalDataRatio(data,nPosesCell,particleProbs,likePxIdxCells,likesIm,countsIm,templateStruct,cellParams,posesStruct,dirtyRegion,ratiosIm,logLikeCell,params);
        probOn = doBP(data,posesStruct,likePxIdxCells,cellMapStruct,cellParams,params,ruleStruct,templateStruct);
        [cellType,cellLocIdx,probBrickOn] = getMostSalient(particles,probOn,logProbCellRatioOldParticle,defaultLogLikeIm);
        dirtyRegion = findCellBounds(cellType,cellLocIdx,cellParams);
        
        newParticles = cell(params.nParticles,1);
        newLikes = cell(params.nParticles,1);
        newCounts = cell(params.nParticles,1);
        
        for(n=1:params.nParticles)
            particleId = find(mnrnd(1,particleProbs),1,'first');
            likesParticle = likesIm{particleId};
            countsParticle = countsIm{particleId};
            
            particle = particles{particleId};
            % setup for sampling
            particle = cat(2,particle,zeros(6,1));
            particle(1,end) = rand(1,1) < probBrickOn;
            particle(2,end) = cellType;
            particle(3,end) = cellLocIdx; 
            
            % bricks: on/off, type, cellCentreIndex,[poseX,Y,theta]            
            [pose,newLike,newCount] = samplePose(data,likesParticle,countsParticle,ratiosImOldParticle{particleId},likePxIdxCells,posesStruct,cellType,cellLocIdx);
            particle(4:6,end) = pose;

            newParticles{n} = particle;
            newCounts{n} = newCount;
            newLikes{n} = newLike;
            
            ratiosIm{n} = ratiosImOldParticle{particleId};
            logLikeCell{n} = logProbCellRatioOldParticle{particleId};
            
        end
        
        particles = newParticles;
        particleProbs = ones(numel(particles),1)/numel(particles); %uniform
        likesIm = newLikes;
        countsIm = newCounts;
        
        
        allParticles{end+1} = particles;

        brickIdx=brickIdx+1;

        figure(200); subplot(1,3,1); imshow(data);
        st = viewAllParticles(newParticles,templateStruct,params);
        subplot(1,3,2); imshow(st);
        st2 = viewOverlayTest(data,newParticles,templateStruct,params);
        subplot(1,3,3); imshow(st2);
        pause(0.2);
        
    end
end

function [logProbCellRatio,ratiosIm,defaultLogLikeIm] = evalDataRatio(data,nPosesCell,particleProbs,likePxIdxCells,likesIm,countsIm,templateStruct,cellParams,posesStruct,dirtyRegion,ratiosImOld,logLikeCellOld,params)
    
    logProbCellRatio = cell(numel(particleProbs),1);
    ratiosIm = cell(numel(particleProbs),1);
    defaultLogLikeIm = zeros(numel(particleProbs),1);

    for (i=1:numel(particleProbs))
        
        defaultLogLikeIm(i) = sum(log(likesIm{i}(:)./countsIm{i}(:)));
        %ratio ONLY
        temp = evalNewLikeRatio(data,templateStruct,likesIm{i},countsIm{i},posesStruct,dirtyRegion,ratiosImOld{i},params);
        ratiosIm{i} = temp;
        
        logProbCellRatio{i} = getLogLikeCellRatio(ratiosIm{i},cellParams,likePxIdxCells,dirtyRegion,nPosesCell,logLikeCellOld{i});
    end
end

function [type,cellLocIdx,probOn,val] = getMostSalient(particles,probOn,logProbCellRatio,defaultLogLikeIm)
    nParticles = numel(logProbCellRatio);
    nTypes = numel(logProbCellRatio{1});
    combinedEvidenceOn = cell(nTypes,1);
    combinedEvidenceOff = cell(nTypes,1);
    
    for(n=1:nTypes)
        temp = zeros(size(logProbCellRatio{1}{n},1),nParticles);
        temp2 = zeros(size(logProbCellRatio{1}{n},1),nParticles);
        for (i=1:nParticles)
            temp(:,i) = defaultLogLikeIm(i) + logProbCellRatio{i}{n} + log(probOn{n}); % need particle prob too
            temp2(:,i) = defaultLogLikeIm(i) + log(1-probOn{n}); % need particle prob too
        end
        combinedEvidenceOn{n} = logsum(temp,2);
        combinedEvidenceOff{n} = logsum(temp2,2);
    end
    
    nTry = 0;
    nTotLoc = 0;
    for (n=1:numel(combinedEvidenceOn))
        nTotLoc = nTotLoc + numel(combinedEvidenceOn{n});
    end
    
    particleUse = particles{1}; %just need one
    
    while(1)
        
        if (nTry >= nTotLoc)
            type = 0; cellLocIdx = 0; val = -inf;
            break;            
        end
        
        winners = zeros(numel(combinedEvidenceOn),2);
        for (i=1:numel(combinedEvidenceOn))
            [val,win] = max(combinedEvidenceOn{i});
            winners(i,:) = [val,win];
        end
        [val,type] = max(winners(:,1));
        cellLocIdx = winners(type,2);
    
        if (any((getType(particleUse) == type) & (getLocIdx(particleUse) == cellLocIdx)))
            combinedEvidenceOn{type}(cellLocIdx) = -Inf;
            display(['Ignoring already-found salient brick']);
            nTry = nTry + 1;
        else
            break;
        end
    end
    logProbOn = combinedEvidenceOn{type}(cellLocIdx)-logsum([combinedEvidenceOn{type}(cellLocIdx),combinedEvidenceOff{type}(cellLocIdx)],2);
    probOn = exp(logProbOn);
    
end