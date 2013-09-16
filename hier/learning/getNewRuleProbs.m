function newRuleProbs = getNewRuleProbs(ruleStruct,msgs,probOn)
    newRuleProbs = zeros(size(ruleStruct.probs));
    
    nEx = numel(msgs);
    for (i=1:nEx)
    
        for (n=1:nTypes)
            % WRONG! Doesn't take into account image evidence
            inds= ruleStruct.parents==n;
            ruleProbTemp = combineMsgs(cat(3, ...
                                       msgs.uFb2ToRb{n}, ...
                                       msgs.uRbToFb2{n})); %equivalent. See factor graph.
            % weight avg prob on by activation
            ruleProbTemp = bsxfun(@plus, log(ruleProbTemp), log(probOn{qq}{n}));
            ruleProbTemp = logsum(ruleProbTemp,1);
            newRuleProbs(inds) = exp(ruleProbTemp-logsum(ruleProbTemp,2));
        end
    end

end
