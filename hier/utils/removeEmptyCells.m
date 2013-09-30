function [x] = removeEmptyCells(x)
% columns only
    temp = numel(x)-sum(cellfun(@isempty,x));
    x=x(1:temp);
end

