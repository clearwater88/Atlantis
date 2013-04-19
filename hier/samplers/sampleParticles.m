function sampleParticles(data,saliencyMap,likePxStruct,allProbMapCells,cellParams,params,ruleStruct,templateStruct)

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
            
            connChild{brickIdx} = [];
            connPar{brickIdx} = [];
            
            %[connChild,connPar,connOK] = sampleParents2(i,bricks(:,1:i),connChild,connPar,ruleStruct,allProbMaps);
            sampleParents(brickIdx,particle,connChild,connPar,ruleStruct,allProbMapCells);
            % bricks: on/off, type, cellCentreIndex,[poseX,Y,theta]
            particle(1,end) = 1; % brick on, lets say
      
            pose = samplePose(like{particleId}, counts{particleId}, likePxStruct,cellType,cellLocIdx,cellParams,params);
            particle(4:6,end) = pose;
 
            
            
            [connChild,connPar,connOK] = sampleChildren(brickIdx,allProbMapCells,particle,ruleStruct,connChild,connPar,params);
            
            if(connOK)
                connOK
            end
       
        end
        particles{1} = particle;
        
        brickIdx=brickIdx+1;
    end
end

