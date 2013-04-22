function sampleParticles(data,saliencyMap,likePxStruct,probMapCells,cellParams,params,ruleStruct,templateStruct)

    particles{1} = [];
    particleProbs  = 1;

    [likeTemp,countsTemp] = initLike(templateStruct,data);
    like{1} = likeTemp;
    counts{1} = countsTemp;
    
    connChild = {};
    connPar = {};
            
    brickIdx = 1;
    while(1)
        display(['On ind: ', int2str(brickIdx)]);
        
        [cellType,cellLocIdx] = getNextSaliencyLoc(saliencyMap,particles{1});
        
        %for(n=1:params.nParticles)
        for (n=1:1)
            particleId = mnrnd(1,particleProbs)==1;
            particle = particles{particleId};
            
            % setup for sampling
            particle = cat(2,particle,zeros(6,1));
            particle(2,end) = cellType;
            particle(3,end) = cellLocIdx; 
            
            connChild{brickIdx} = zeros(1,ruleStruct.maxChildren);
            connPar{brickIdx} = [];
            
            %[connChild,connPar,connOK] = sampleParents2(i,bricks(:,1:i),connChild,connPar,ruleStruct,allProbMaps);
            [state,connPar,connChild] = sampleParents(brickIdx,particle,connChild,connPar,ruleStruct,probMapCells,like{particleId}, counts{particleId},likePxStruct,cellParams,params);
            % bricks: on/off, type, cellCentreIndex,[poseX,Y,theta]
            particle(1,end) = state;
      
            pose = samplePose(like{particleId}, counts{particleId}, likePxStruct,cellType,cellLocIdx,cellParams);
            particle(4:6,end) = pose;
 
            if (particle(1,end) == 1)
                [connChild,connPar] = sampleChildren(brickIdx,probMapCells,particle,ruleStruct,connChild,connPar,params);
            end
                
       
        end
        particles{1} = particle;
        
        brickIdx=brickIdx+1;
    end
end

