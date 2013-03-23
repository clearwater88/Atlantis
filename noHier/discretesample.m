function [res] = discretesample(p, n)
    res = zeros(1,n);

    cp = cumsum(p);
    sp = rand(n,1);
    for (i=1:n)
       res(i) = find(sp(i) < cp,1,'first'); 
    end
end

