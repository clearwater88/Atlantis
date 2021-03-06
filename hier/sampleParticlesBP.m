function [allParticles,probOn,probOnFinal,msgs] = sampleParticlesBP(data,posesStruct,likePxIdxCells,cellMapStruct,cellParams,params,ruleStruct,templateStruct,imSize)

    verbose = 0;

    nTypes = numel(cellParams.centres);

    [likeTemp,countsTemp] = initLike(data,templateStruct);
    particles{1} = [];
    
    particleProbs  = 1;
    
    likesIm{1} = likeTemp;
    countsIm{1} = countsTemp;
    allParticles = {};

    % initialize
    brickIdx = 1;
    dirtyRegion = [];
   
    ratiosIm = cell(params.nParticles,1);
    logLikeCell = cell(params.nParticles,1);
    nPosesCell = getNumPoses(likePxIdxCells);
    probOn = cell(params.thingsToSee,1);
    
    [rotTemplates,~] = getRotTemplates(params,templateStruct.app);
    
    for (qq=1:params.thingsToSee);
        
        display(['bp iter: ', int2str(qq)]);
        
        [logProbCellRatioOldParticle,ratiosImOldParticle,defaultLogLikeIm] = ...
            evalDataRatio(data,nPosesCell,particleProbs,likePxIdxCells,likesIm,countsIm,templateStruct,cellParams,posesStruct,dirtyRegion,ratiosIm,logLikeCell,params,templateStruct.sizes);
        
        sOn = getProbOn(particles);
        if(params.useContext)
            %clampToOff = qq==params.thingsToSee;
            clampToOff = 0;
            [probOn{qq},msgs] = doBP(cellMapStruct,cellParams,params,ruleStruct,sOn,imSize,clampToOff);
        else
            msgs = [];
            temp = cell(nTypes,1);
            for (n=1:nTypes)
                nBricks = prod(cellParams.coordsSize(n,:),2);
                temp{n} = params.probRoot(n)*ones(nBricks,1);
            end
            probOn{qq} = temp;
        end
        
        [cellType,cellLocIdx,probBrickOn] = getMostSalient(particles,probOn{qq},logProbCellRatioOldParticle,defaultLogLikeIm);
        
        newParticles = cell(params.nParticles,1);
        newLikes = cell(params.nParticles,1);
        newCounts = cell(params.nParticles,1);
        
        temp = zeros(numel(logProbCellRatioOldParticle),1);
        for (pp=1:numel(logProbCellRatioOldParticle))
            temp(pp) = logProbCellRatioOldParticle{pp}{cellType}(cellLocIdx);
        end
       
        display(['type: ', int2str(cellType)]);
        display(['on in prior: ', num2str(probOn{qq}{cellType}(cellLocIdx))]);
        display(['probBrickOn: ', num2str(probBrickOn)]);
        
        for(n=1:params.nParticles)
            particleId = find(mnrnd(1,particleProbs),1,'first');
            likesParticle = likesIm{particleId};
            countsParticle = countsIm{particleId};
            
            ratiosIm{n} = ratiosImOldParticle{particleId};
            logLikeCell{n} = logProbCellRatioOldParticle{particleId};
            
            particle = particles{particleId};
            % setup for sampling
            particle = cat(2,particle,zeros(6,1));
            particle(1,end) = rand(1,1) < probBrickOn;
            particle(2,end) = cellType;
            particle(3,end) = cellLocIdx; 
            
            % bricks: on/off, type, cellCentreIndex,[poseX,Y,theta]            
            [pose,newLike,newCount] = samplePose(data,likesParticle,countsParticle,ratiosImOldParticle{particleId},likePxIdxCells,posesStruct,cellType,cellLocIdx,templateStruct.mix);
            temp = newLike./newCount;
            assert(~any(temp(:) > 1.0001));
            particle(4:6,end) = pose;

            newParticles{n} = particle;
            newCounts{n} = newCount;
            newLikes{n} = newLike;
        end
        
        dirtyRegion = findCellBounds(cellType,cellLocIdx,cellParams);
        
        maxSz= (max(templateStruct.sizes(cellType,:))+1)/2;
        
        dirtyRegion(1:2,1) = dirtyRegion(1:2,1)-maxSz;
        dirtyRegion(1:2,2) = dirtyRegion(1:2,2)+maxSz;
        
        if(qq==params.thingsToSee)
            
        end
        
         pt=particle(:,end);
         ptType=pt(2);
         ptCentre=pt(4:5);
         agInd=find(abs(posesStruct.angles-pt(6)) < 0.0001);
         rt=rotTemplates{ptType,agInd};
         mask=posesStruct.mask{ptType}{agInd}==1;
         
         sz=(size(rt)-1)/2;
         dataUse=data(ptCentre(1)-sz(1):ptCentre(1)+sz(1),ptCentre(2)-sz(2):ptCentre(2)+sz(2));
         
         r1= evalLikePixels(rt,dataUse,mask,1);
         r1=sum(log(r1(mask)));
         
         r2=evalLikePixels(templateStruct.app{end},dataUse,mask,1);
         r2=sum(log(r2(mask)));
         
         assert(r1>r2);
         
         particles = newParticles;
         particleProbs = ones(numel(particles),1)/numel(particles); %uniform
         likesIm = newLikes;
         countsIm = newCounts;
        
        allParticles{end+1} = particles;

        brickIdx=brickIdx+1;  
        if(probBrickOn < 0.01)
            break;
        end
         
        if(verbose)
            figure(200); subplot(1,3,1); imshow(data);
            st = viewAllParticles(particles,rotTemplates,params,imSize);
            subplot(1,3,2); imshow(st);
            st2 = viewOverlayTest(data,particles,rotTemplates,params,imSize);
            subplot(1,3,3); imshow(st2);
            title(['r1,r2: ', num2str(r1),',',num2str(r2)]);
        end 
    end
    
    % clamp here; just need final msgs of the active set
    if(params.useContext)
        %clampToOff = qq==params.thingsToSee;
        clampToOff = 1;
        
        [probOnFinal,msgs] = doBP(cellMapStruct,cellParams,params,ruleStruct,sOn,imSize,clampToOff);
        
        
    else
        msgs = [];
        temp = cell(nTypes,1);
        for (n=1:nTypes)
            nBricks = prod(cellParams.coordsSize(n,:),2);
            temp{n} = params.probRoot(n)*ones(nBricks,1);
        end
        probOnFinal = temp;
    end
end

function [logProbCellRatio,ratiosIm,defaultLogLikeIm] = evalDataRatio(data,nPosesCell,particleProbs,likePxIdxCells,likesIm,countsIm,templateStruct,cellParams,posesStruct,dirtyRegion,ratiosImOld,logLikeCellOld,params,templateSizes)
    
    logProbCellRatio = cell(numel(particleProbs),1);
    ratiosIm = cell(numel(particleProbs),1);
    defaultLogLikeIm = zeros(numel(particleProbs),1);

    for (i=1:numel(particleProbs))
        
        temp = evalLike(likesIm{i},countsIm{i},params.alpha);
        defaultLogLikeIm(i) = sum(log(temp(:)));
        %ratio ONLY
        temp = evalNewLikeRatio(data,templateStruct,likesIm{i},countsIm{i},posesStruct,dirtyRegion,ratiosImOld{i},params);
        ratiosIm{i} = temp;
        
        logProbCellRatio{i} = getLogLikeCellRatio(ratiosIm{i},cellParams,likePxIdxCells,dirtyRegion,nPosesCell,logLikeCellOld{i},templateSizes);
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