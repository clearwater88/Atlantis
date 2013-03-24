function [bricks,conn] = createBricks(poseCellLocs)

    % on/off, type, [cellCentreX,Y,Theta],[poseOffsetFromCentreX,Y,theta]
    nBricks = 200;
    bricks(1,:) = double(rand(1,nBricks) > 0.5);
    bricks(2,:) = 1 + double(rand(1,nBricks)>0.5);
    
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
    
    % rule, child1...childN in reference to bricks
    conn = {};
    
    
    
end

