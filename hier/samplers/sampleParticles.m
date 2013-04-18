function sampleParticles(data,allProbMapCells,cellParams,params,ruleStruct,templateStruct)

    particles{1} = [];
    particleProbs  = 1;

    [likeTemp,countsTemp] = initLike(templateStruct,data);
    like{1} = likeTemp;
    counts{1} = countsTemp;

%     [likePxStruct] = evalLike(data,templateStruct,params); 
%     save('likePxStruct','likePxStruct');
    load('likePxStruct');
 
%     data = dataRand(params.imSize);
%     saliencyMap = getLikeCell(likePxStruct,cellParams,params);
%     save('saliency','saliencyMap','data');
    load('saliency');
    
    connChild = {};
    connPar = {};
            
    ind = 1;
    while(1)
        display(['On ind: ', int2str(ind)]);
        
        [cellType,cellLocIdx] = getNextSaliencyLoc(saliencyMap,particles{1});
        
        %for(n=1:params.nParticles)
        for (n=1:1)
            particleId = mnrnd(1,particleProbs)==1;
            particle = particles{particleId};
            
            % setup for sampling
            particle = cat(2,particle,zeros(6,1));
            connChild{ind} = [];
            connPar{ind} = [];
            
            %[connChild,connPar,connOK] = sampleParents2(i,bricks(:,1:i),connChild,connPar,ruleStruct,allProbMaps);
            sampleParents(particleId,particle,connChild,connPar,ruleStruct,allProbMaps);
            % bricks: on/off, type, cellCentreIndex,[poseX,Y,theta]
            particle(1,end) = 1; % brick on, lets say
            particle(2,end) = cellType;
            particle(3,end) = cellLocIdx;       
            pose = samplePose(like{particleId}, counts{particleId}, likePxStruct,cellType,cellLocIdx,cellParams,params);
            particle(4:6,end) = pose;
 
            
            
            [connChild,connPar,connOK] = sampleChildren(ind,allProbMapCells,particle,ruleStruct,connChild,connPar,params);
            
            if(connOK)
                connOK
            end
       
        end
        particles{1} = particle;
        
        ind=ind+1;
    end
end

