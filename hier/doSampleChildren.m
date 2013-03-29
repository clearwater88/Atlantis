function res = doSampleChildren(probMap,nChildren)
    % access allProbMaps with probMap{ruleId,slot,loc index}
    res = zeros(nChildren,1);
    for (i=1:nChildren)
        res(i)=find(mnrnd(1,probMap)==1);
    end
end

