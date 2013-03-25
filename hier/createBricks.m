function [bricks,conn,rules] = createBricks(poseCellLocs,ruleStruct)

    % on/off, type, [cellCentreX,Y,Theta],[poseOffsetFromCentreX,Y,theta]
    nBricks = 200;
    bricks(1,:) = double(rand(1,nBricks) > 0.5);
    bricks(2,:) = 1 + double(rand(1,nBricks)>0.9);
    
    for (i=1:nBricks)
        type = bricks(2,i);
        randInd = randi(size(poseCellLocs{type},1),1,1);
        bricks(3:5,i) = poseCellLocs{type}(randInd,:)';    
    end
    bricks(6:7,:) = round(2*rand(2,nBricks)-1); % round offsets to integer
    bricks(8,:) = mod(0.1*randn(1,nBricks),2*pi);
    
%     randInds = randi(size(poseCellLocs{1},1),nBricks,1);
%     bricks(3:5,:) = poseCellLocs{1}(randInds,:)';
%     bricks(6:7,:) = round(2*rand(2,nBricks)-1); % round offsets to integer
%     bricks(8,:) = mod(0.1*randn(1,nBricks),2*pi);
    
    % rule, child1...childN in reference to bricks indices
    conn = {};
    rules = zeros(1,size(bricks,2));
    for (i=1:size(bricks,2))
        
        type = bricks(2,i);
        ids = ruleStruct.parents==type;
        ruleProbs = ruleStruct.probs.*(ids==1); %mask out invalid rules
        rules(i) = find(mnrnd(1,ruleProbs)==1);
          
        rulePick = ruleStruct.children(rules(i),:);
        
        children = zeros(1,ruleStruct.maxChildren);
        for (j=1:size(rulePick,2))
            typeUse = rulePick(j); 
            
            % type 0? then no more symbols left to do
            if(typeUse == 0) break; end;
            
            childBrickIds = find(bricks(2,:) == typeUse);
            children(j) = childBrickIds(randi(numel(childBrickIds),1));
        end
        
        conn{i} = children;
        %sampleRule = randsample(
        
        %probs = ruleStruct.probs(
    end
    
    
    
end

