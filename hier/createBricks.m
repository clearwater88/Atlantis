function [bricks,connChild,connPar,rules] = createBricks(allProbMaps,poseCellLocs,ruleStruct)

    % on/off, type, cellCentreIndex,[poseOffsetFromCentreX,Y,theta]
    nBricks = 200;
    bricks(1,:) = double(rand(1,nBricks) > 0.1);
    bricks(2,:) = 1 + double(rand(1,nBricks)>0.9);
    
    for (i=1:nBricks)
        type = bricks(2,i);
        randInd = randi(size(poseCellLocs{type},1),1,1);
        bricks(3,i) = randInd;
    end
    bricks(4:5,:) = round(2*rand(2,nBricks)-1); % round offsets to integer
    bricks(6,:) = mod(0.1*randn(1,nBricks),2*pi);
    
    % rule, child1...childN in reference to bricks indices
    % determine connChildections
    connChild = cell(size(bricks,2),1);
    connPar = cell(size(bricks,2),1);
    rules = zeros(1,size(bricks,2));
    for (i=1:size(bricks,2))
        connChild{i} = zeros(1,ruleStruct.maxChildren);
        connPar{i} = [];
    end    
    
    tic
    for (childId=1:size(bricks,2))
        if(bricks(1,childId) == 0) continue; end; %not on? then you don't geto a parent
        [connChild,connPar,connOK] = sampleParents(childId,bricks,connChild,connPar,ruleStruct,allProbMaps);
    end
    toc
    
    
%     for (i=1:size(bricks,2))
% %         
% %         type = bricks(2,i);
% %         ids = ruleStruct.parents==type;
% %         ruleProbs = ruleStruct.probs.*(ids==1); %mask out invalid rules
% %         rules(i) = find(mnrnd(1,ruleProbs)==1);
% %           
% %         rulePick = ruleStruct.children(rules(i),:);
% %         
%         children = zeros(1,ruleStruct.maxChildren);
% %         for (j=1:size(rulePick,2))
% %             typeUse = rulePick(j); 
% %             
% %             % type 0? then no more symbols left to do
% %             if(typeUse == 0) break; end;
% %             
% %             childBrickIds = find(bricks(2,:) == typeUse);
% %             children(j) = childBrickIds(randi(numel(childBrickIds),1));
% %         end
% %         
%         connChild{i} = children;
%     end    
end

