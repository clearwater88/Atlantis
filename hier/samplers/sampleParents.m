function sampleParents(particleId, bricks,connChild,connPar,ruleStruct,allProbMaps)
%SAMPLEPARENTS sample parents for this particle

    for (parentId=1:size(bricks,2))
        if(parentId==particleId) continue; end;
        if(bricks(1,parentId) == 0) continue; end; %brick off? then can't be parent
        
    end
end

