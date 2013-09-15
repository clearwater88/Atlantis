function [res] = getLocIdx(bricks,id)
    if (isempty(bricks))
        res = [];
    else
        if (nargin < 2)
            res = bricks(3,:);
        else
            res = bricks(3,id);
        end
    end
end

