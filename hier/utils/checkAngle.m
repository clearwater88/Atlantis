function res = checkAngle(ag,low,high)
    % does not assume anything about range of low, high

    low= mod(low+pi,2*pi)-pi;
    high= mod(high+pi,2*pi)-pi;
    ag = mod(ag+pi,2*pi)-pi;
        
    res1 = bsxfun(@and,bsxfun(@ge,ag,low),bsxfun(@le,ag,high));
    res2 = bsxfun(@and,bsxfun(@ge,low,high), ...
              bsxfun(@or,bsxfun(@ge,ag,low),bsxfun(@le,ag,high)));
    res = bsxfun(@or,res1,res2);
    
end

