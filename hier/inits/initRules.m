function [ruleStruct] = initRules()
    % rules are 1-based index.
    % 0 indicates sentinel.
    rules = [1,0,0,0; ...
             1,2,2 0; ...
             1,2,2,2; ...
             2,0,0,0; ...
             2,3,3 0; ...
             2,3,3,3; ...
             3,0,0,0];

%     rules = [1,0,0,0; ...
%              2,0,0,0; ...
%              3,0,0,0];

    nSymbols = max(rules(:,1));
    ruleProbs = zeros(size(rules,1),1);
    for (i=1:nSymbols)
        ids = rules(:,1)==i;
        r = rules(ids,:);
        nr = size(r,1);
        temp = ones(nr,1);
        temp = temp/sum(temp);
        ruleProbs(ids) = temp;
    end

    ruleStruct.rules = rules;
    ruleStruct.parents = rules(:,1);
    ruleStruct.children = rules(:,2:end);
    ruleStruct.probs = ruleProbs;
    ruleStruct.maxChildren = size(ruleStruct.children,2);
    
    ruleStruct.toString = @toString;
end

function [res] = toString(ruleStruct)
    error('Not implemented');
end




