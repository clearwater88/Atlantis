function res = jIsMemberRows(a,s)
    % alternative to ismember with 'rows' argument. This is just 2 lines...
    res = bsxfun(@eq,a,s);
    res = (sum(res,2)/size(res,2)) == 1;
end

