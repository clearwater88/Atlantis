function [res] = combineLogMsgs(msgs)
    %msgs: nData x nOptions x nFactors
    
    res = sum(log(msgs),3);
    res = bsxfun(@minus,res,logsum(res,2));

%     res = prod(msgs,3);
%     res = bsxfun(@rdivide, res,sum(res,2));
    
end

