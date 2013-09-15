function [res] = isSelfRooted(bricks,connPar)
    res = cellfun(@(x) isempty(x), connPar); % find bricks with no parents
    if(~isempty(bricks))
        res = res & (getOn(bricks) == 1);
    else
        res = [];
    end    
end

