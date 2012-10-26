function [res] = logsum(arr,dim)
    m = max(arr,[],dim);
    res = bsxfun(@plus,log(sum(exp(bsxfun(@minus,arr,m)),dim)),m);
end

