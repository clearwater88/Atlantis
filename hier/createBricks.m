function [bricks,connChild,connPar] = createBricks(allProbMaps,poseCellLocs,ruleStruct,probRoot)

    % on/off, type, cellCentreIndex,[poseOffsetFromCentreX,Y,theta]
    nBricks = 500;
    probOn = 1;
    
    bricks = zeros(6,nBricks);
    
    % rule, child1...childN in reference to bricks indices
    % for connections
    connChild = cell(nBricks,1);
    connPar = cell(nBricks,1);
    for (i=1:nBricks)
        connChild{i} = zeros(1,ruleStruct.maxChildren);
        connPar{i} = [];
    end
    
    % might put brick into same pose cell. don't do that
    for (i=1:nBricks)
       bricks(1,i) = double(rand(1) > 1-probOn);
       type = 1 + double(rand(1)>0.1);
       bricks(2,i) = type;
       
       poseCells = poseCellLocs{type};
       poseCellProbs = ones(size(poseCells,1),1)/size(poseCells,1);
       
       active = isInActiveSet(bricks(:,1:i-1),type,numel(poseCells))==1;
       poseCellProbs(active) = 0;
       poseCellProbs = poseCellProbs/sum(poseCellProbs);
       
       loc = find(mnrnd(1,poseCellProbs)==1);
       % make sure we didn't sample the same brick twice
       assert(~any(bricks(2,1:i-1) == type & bricks(3,1:i-1) == loc))
       bricks(3,i) = loc;
       
       bricks(4:5,i) = round(2*rand(2,1)-1); % round offsets to integer
       bricks(6,i) = mod(0.1*randn(1),2*pi);
       
       if(bricks(1,i) == 0) continue; end; %not on? then you don't geto a parent

       [connChild,connPar,connOK] = sampleParents(i,bricks(:,1:i),connChild,connPar,ruleStruct,allProbMaps);
       [connChild,connPar,connOK] = sampleChildren(i,allProbMaps,bricks(:,1:i),ruleStruct,connChild,connPar,poseCellLocs,probRoot);
    end


%     % rule, child1...childN in reference to bricks indices
%     % determine connChildections
%     connChild = cell(size(bricks,2),1);
%     connPar = cell(size(bricks,2),1);
%     rules = zeros(1,size(bricks,2));
%     for (i=1:size(bricks,2))
%         connChild{i} = zeros(1,ruleStruct.maxChildren);
%         connPar{i} = [];
%     end    
%     
%     tic
%     for (childId=1:size(bricks,2))
%         if(bricks(1,childId) == 0) continue; end; %not on? then you don't geto a parent
%         [connChild,connPar,connOK] = sampleParents(childId,bricks,connChild,connPar,ruleStruct,allProbMaps);
%     end
%     toc
%     
    
end

