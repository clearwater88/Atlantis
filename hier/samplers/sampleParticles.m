function [allParticles,allConnPars,allConnChilds,saliencyScores] = sampleParticles(data,probMapCells,cellParams,params,ruleStruct,templateStruct)
    [likeTemp,countsTemp] = initLike(data,templateStruct);
    [likePxStruct] = evalLike(data,templateStruct,zeros(size(data)),zeros(size(data)),params);
    
    nPosesCell = getNumPoses(cellParams,likePxStruct);
    
    particles{1} = [];
    particleProbs  = 1;
    
    likes{1} = likeTemp;
    counts{1} = countsTemp;
    connChilds{1} = {}; % who its children can be
    connPars{1} = {}; % who its parents are
    
    allParticles = {};
    allConnPars = {};
    allConnChilds = {};
    saliencyScores = [];

    % initialize
    brickIdx = 1;
    dirtyRegion = [];
    ratiosIm = cell(params.nParticles,1);
    logLikeCell = cell(params.nParticles,1);
    
    % precompute
    likePxIdxCells = cell(cellParams.nTypes,1);
    for (n=1:cellParams.nTypes)
        likePxIdxCells{n}=getLikePxIdxAll(cellParams.centres{n}, ...
                                          cellParams.dims(n,:), ...
                                          likePxStruct.boundaries{n});
    end
    
    while(1)
        display(['On ind: ', int2str(brickIdx)]);
    
        if(brickIdx > 75)
            break;
        end
        for (i=1:numel(particles))
           logProbParticle(i) =  evalParticleLogProbPrior(particles{i},connChilds{i}, connPars{i}, ruleStruct, nPosesCell, probMapCells, params);
           logProbParticle(i) = logProbParticle(i) + sum(log(likes{i}(:)./counts{i}(:)));
        end
        
        [cellType,cellLocIdx,saliencyScores(end+1),ratiosImOldParticle,logLikeCellOldParticle,logProbOptionsAll,logPsumGNoPoint,logPsumG,stop] = ...
            getNextSaliencyLoc(particles,likes,counts,particleProbs,dirtyRegion,nPosesCell,likePxStruct,ratiosIm,logLikeCell,likePxIdxCells,connChilds,connPars,cellParams,ruleStruct,probMapCells,params);
                
        % reweight
        logProbOptions = zeros(3,numel(logProbOptionsAll));
        for (i=1:numel(logProbOptionsAll))
           logProbOptions(:,i) = logProbOptionsAll{i}{cellType}(cellLocIdx,:)';
        end
        localizedProbs = logsum(logProbOptions,1);
        
        particleProbs = localizedProbs-logProbParticle;
        particleProbs = exp(particleProbs-logsum(particleProbs,2));
        particleProbs
        
        display(['Cell type: ', int2str(cellType)]);
        
        dirtyRegion = findCellBounds(cellType,cellLocIdx,cellParams);
        
        if (stop) break; end;
    
        newParticles = cell(params.nParticles,1);
        newLikes = cell(params.nParticles,1);
        newCounts = cell(params.nParticles,1);
        newConnChilds = cell(params.nParticles,1);
        newConnPars = cell(params.nParticles,1);

        
        for(n=1:params.nParticles)
            particleId = find(mnrnd(1,particleProbs),1,'first');
            particle = particles{particleId};
            
            likesParticle = likes{particleId};
            countsParticle = counts{particleId};
            connChild = connChilds{particleId};
            connPar = connPars{particleId};

            % setup for sampling
            particle = cat(2,particle,zeros(6,1));
            particle(2,end) = cellType;
            particle(3,end) = cellLocIdx; 
            
            % who its children can be
            connChild{end+1} = zeros(1,ruleStruct.maxChildren);
            % who its parents are
            connPar{end+1} = [];
            
            %logProbOptions = logProbOptionsAll{particleId}{cellType}(cellLocIdx,:)';
            parentSlotProbs = sampleParentSlots(cellType, cellLocIdx, particle,connChild,ruleStruct,probMapCells);
            
            logPsumGNoPointUse = logPsumGNoPoint{particleId}{cellType}(cellLocIdx,:)';
            logPsumGUse = logPsumG{particleId};
            noConnectParent = exp(logPsumGNoPointUse-logPsumGUse);
            
            probOptions = exp(logProbOptions(:,i) - logsum(logProbOptions(:,i),1));
            probOptions = probOptions/sum(probOptions); % fucking matlab
            
            optionId = find(mnrnd(1,probOptions)==1);

            particle(1,end) = optionId ~= 1;
            
            switch (optionId)
                case 1
                    a=1; %pass
                case 2
                    [connChild,connPar] = sampleChildren(brickIdx,probMapCells,particle,ruleStruct,connChild,connPar,params);
                case 3
                    [connChild,connPar] = sampleParents(brickIdx,connChild,connPar,noConnectParent,parentSlotProbs);
                    [connChild,connPar] = sampleChildren(brickIdx,probMapCells,particle,ruleStruct,connChild,connPar,params);
                otherwise
                    error('Bad optionId');
            end
            
            % bricks: on/off, type, cellCentreIndex,[poseX,Y,theta]            
            [pose,newLike,newCount] = samplePose(likesParticle,countsParticle,likePxStruct,cellType,cellLocIdx,cellParams);
            particle(4:6,end) = pose;

            newParticles{n} = particle;
            newCounts{n} = newCount;
            newLikes{n} = newLike;
            newConnPars{n} = connPar;
            newConnChilds{n} = connChild;
            
            ratiosIm{n} = ratiosImOldParticle{particleId};
            logLikeCell{n} = logLikeCellOldParticle{particleId};
        end
        particles = newParticles;
        particleProbs = ones(numel(particles),1)/numel(particles); %uniform
        likes = newLikes;
        counts = newCounts;
        connPars = newConnPars;
        connChilds = newConnChilds;
        
        
        allParticles{end+1} = particles;
        allConnPars{end+1} = connPars;
        allConnChilds{end+1} = connChilds;

        brickIdx=brickIdx+1;
        %save('tempRes','allParticles','allParticleProbs','allLikes','allCounts','allConnPars','allConnChilds','templateStruct','saliencyScores','params','data','-v7.3');
        
        %figure(1); subplot(1,2,1); imshow(data);
        %st = viewAllParticles(newParticles,templateStruct,params.imSize);
        %subplot(1,2,2); imshow(st);
        %pause(0.2);

    end
end