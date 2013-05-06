function [res] = getOn(bricks,id)
    if (isempty(bricks))
        res = [];
    else

        if (nargin < 2)
            res = bricks(1,:);
        else
            res = bricks(1,id);
        end
    end
end

