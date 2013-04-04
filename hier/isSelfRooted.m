function [res] = isSelfRooted(bricks,brickType,connPar,sz)
    
    selfRoot = cellfun(@(x) isempty(x), connPar); % find bricks with no parents
    validBricks = (bricks(1,:) == 1) & ...
                  (bricks(2,:) == brickType);

    selfRoot = selfRoot(validBricks);
    locs = bricks(3,validBricks);
    
    res = ones(sz,1);
    res(locs) = selfRoot;
    
    % if brick is off, it doesn't root itself
    offBricks = (bricks(1,:) == 0) & ...
                (bricks(2,:) == brickType);
    offLocs = bricks(3,offBricks);
    res(offLocs) = 0;
    
end

