function [res] = logsum(arr,dim)
    if(nargin < 2)
        dim = 1;
    end
    
    m = max(arr,[],dim);
    res = bsxfun(@plus,log(sum(exp(bsxfun(@minus,arr,m)),dim)),m);
end

