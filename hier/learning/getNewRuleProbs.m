function ruleProbs = getNewRuleProbs(ruleStruct,msgs,probOn)
    
    logNewRuleProbs = zeros(numel(ruleStruct.probs),numel(msgs));
    for (j=1:numel(msgs))
        logNewRuleProbs(:,j) = doGetNewRuleProbs(ruleStruct,msgs{j},probOn{j}{end});
    end
    logNewRuleProbs = logsum(logNewRuleProbs,2);

    nTypes = numel(unique(ruleStruct.parents));
    ruleProbs = zeros(size(ruleStruct.probs));
    for(n=1:nTypes)
       inds = find(ruleStruct.parents == n);
       denom = logsum(logNewRuleProbs(inds),1);
       ruleProbs(inds) = exp(logNewRuleProbs(inds)-denom);
    end
end

function logNewRuleProbsProp = doGetNewRuleProbs(ruleStruct,msg,probOn)
    nTypes = numel(unique(ruleStruct.parents));
    logNewRuleProbsProp = zeros(size(ruleStruct.probs));
    
    for (n=1:nTypes)
        inds= ruleStruct.parents==n;
        temp = combineLogMsgs(cat(3, ...
            msg.uFb2ToRb{n}, ...
            msg.uRbToFb2{n})); %equivalent. See factor graph.
        % weight avg prob on by activation
        temp=max(temp,-10^9); % clamp
        ruleProbTemp = bsxfun(@plus, temp, log(probOn{n}));
        logNewRuleProbsProp(inds) = logsum(ruleProbTemp,1);
    end
end