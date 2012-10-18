function [res] = logsum(arr)
    m = max(arr);
    res = log(sum(exp(arr-m)))+m;
end

