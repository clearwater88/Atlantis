function [allParticles,allParticleProbs,allLikes,allCounts,allConnPars,allConnChilds,saliencyScores] = sampleParticles(data,likePxStruct,probMapCells,cellParams,params,ruleStruct,templateStruct)
    [likeTemp,countsTemp] = initLike(templateStruct,data);
    
    particles{1} = [];
    particleProbs  = 1;
    
    likes{1} = likeTemp;
    counts{1} = countsTemp;
    connChilds{1} = {};
    connPars{1} = {};
            

    allParticles = {};
    allParticleProbs = {};
    allLikes = {};
    allCounts = {};
    allConnPars = {};
    allConnChilds = {};
    saliencyScores = [];

    brickIdx = 1;
    while(1)
        display(['On ind: ', int2str(brickIdx)]);
        
        [cellType,cellLocIdx,saliencyScores(end+1),stop] = getNextSaliencyLoc(data,particles,likes,counts,particleProbs,templateStruct,cellParams,params);
        if (stop) break; end;
    
        newParticles = cell(params.nParticles,1);
        newLikes = cell(params.nParticles,1);
        newCounts = cell(params.nParticles,1);
        newConnChilds = cell(params.nParticles,1);
        newConnPars = cell(params.nParticles,1);

        for(n=1:params.nParticles)
            particleId = mnrnd(1,particleProbs)==1;
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
            
            tic
            [logProbOptions,noConnectParent,parentSlotProbs] = getProbsOn(cellType,cellLocIdx,particle,connChild,connPar,ruleStruct,probMapCells,likesParticle,countsParticle,likePxStruct,cellParams,params);
            toc
            probOptions = exp(logProbOptions - logsum(logProbOptions,1));
            probOptions = probOptions/sum(probOptions); % fucking matlab
            optionId = find(mnrnd(1,probOptions)==1);
        
            particle(1,end) = optionId ~= 1;
            
            switch (optionId)
                case 1
                    
                case 2
                    [connChild,connPar] = sampleChildren(brickIdx,probMapCells,particle,ruleStruct,connChild,connPar,params);
                case 3
                    [connChild,connPar] = sampleParents(brickIdx,connChild,connPar,noConnectParent,parentSlotProbs);
                    [connChild,connPar] = sampleChildren(brickIdx,probMapCells,particle,ruleStruct,connChild,connPar,params);
                otherwise
                    error('Bad optionId');
            end
            
            %[state,connPar,connChild] = sampleParents(brickIdx,particle,connChild,connPar,ruleStruct,probMapCells,like{particleId}, counts{particleId},likePxStruct,cellParams,params);
            % bricks: on/off, type, cellCentreIndex,[poseX,Y,theta]            
            [pose,newLike,newCount] = samplePose(likesParticle,countsParticle,likePxStruct,cellType,cellLocIdx,cellParams);
            particle(4:6,end) = pose;

            newParticles{n} = particle;
            newCounts{n} = newCount;
            newLikes{n} = newLike;
            newConnPars{n} = connPar;
            newConnChilds{n} = connChild;
        end
        particles = newParticles;
        particleProbs = ones(numel(particles),1)/numel(particles); %uniform
        likes = newLikes;
        counts = newCounts;
        connPars = newConnPars;
        connChilds = newConnChilds;
        
        
        allParticles{end+1} = particles;
        allParticleProbs{end+1} = particleProbs;
        allLikes{end+1} = likes;
        allCounts{end+1} = counts;
        allConnPars{end+1} = connPars;
        allConnChilds{end+1} = connChilds;

        

        brickIdx=brickIdx+1;
        save('tempRes','allParticles','allParticleProbs','allLikes','allCounts','allConnPars','allConnChilds','templateStruct','saliencyScores','params','-v7.3');
    end
end