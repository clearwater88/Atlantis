function [ruleStruct] = initRules()
    % rules are 1-based index.
    % 0 indicates sentinel.
    rules = [1,0,0,0; ...
             1,2 0 0; ...
             1,2,2 0; ...
             1,2,2,2];
    ruleProbs = ones(size(rules,1),1);
    ruleProbs = ruleProbs/sum(ruleProbs);
         
         
    ruleStruct.parents = rules(:,1);
    ruleStruct.children = rules(:,2:end);
    ruleStruct.probs = ruleProbs;
end

