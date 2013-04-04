function [res] = isInActiveSet(bricks,type,sz)
    res = zeros(sz,1);
    brickIds = bricks(2,:)==type;
    res(bricks(3,brickIds)) = 1;
end

