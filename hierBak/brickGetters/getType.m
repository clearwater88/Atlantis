function [res] = getType(bricks,id)
    if (isempty(bricks))
        res = [];
    else
        if(nargin < 2)
            res = bricks(2,:);
        else
            res = bricks(2,id);
        end
    end
end

    

