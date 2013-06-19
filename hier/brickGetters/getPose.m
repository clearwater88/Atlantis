function [res] = getPose(bricks,id)
    if (isempty(bricks))
        res = [];
    else
        if (nargin < 2)
            res = bricks(4:6,:);
        else
            res = bricks(4:6,id);
        end
    end
end

