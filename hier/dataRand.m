function [res] = dataRand(imSize)
    res = rand(imSize);
    res = double(res > 0.5);
end

