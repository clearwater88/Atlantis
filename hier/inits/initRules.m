function [ruleStruct] = initRules()
    % rules are 1-based index.
    % 0 indicates sentinel.
    
    rulesWithProb = [1,0,0, 0.1; ...
                     1,2,0, 0.1; ...
                     1,2,2, 0.8; ...
                     2,0,0, 0.1; ...
                     2,3,0, 0.1; ...
                     2,3,3, 0.8; ...
                     3,0,0, 1];

    rules = rulesWithProb(:,1:end-1);
    ruleProbs = rulesWithProb(:,end);
                 
        
         
         
%    nSymbols = max(rules(:,1));
%     ruleProbs = zeros(size(rules,1),1);
%     for (i=1:nSymbols)
%         ids = rules(:,1)==i;
%         r = rules(ids,:);
%         nr = size(r,1);
%         temp = ones(nr,1);
%         temp = temp/sum(temp);
%         ruleProbs(ids) = temp;
%     end

    ruleStruct.rules = rules;
    ruleStruct.parents = rules(:,1);
    ruleStruct.children = rules(:,2:end);
    ruleStruct.probs = ruleProbs;
    ruleStruct.maxChildren = size(ruleStruct.children,2);
    ruleStruct.probHist(:,1) = ruleStruct.probs;
    
    ruleStruct.toString = @toString;
    
    
    % perform checks
    types = unique(ruleStruct.parents);
    % check first rule for given type is null rule
    for (n=1:numel(types))
        id = find(ruleStruct.parents==n,1,'first');
        children = ruleStruct.children(id,:);
        assert(~any(children~=0));
    end
    
    % check that rule types in slots are grouped together
    for (n=1:numel(types))
       rulesInd = ruleStruct.parents==n;
       rules = ruleStruct.rules(rulesInd,2:end);
       if(isempty(rules)) continue; end;
       for (k=1:size(rules,3))
           
          slice = diff(rules(:,k)); 
          assert(~any(slice < 0));
       end
    end
    
    
    
end

function [res] = toString(ruleStruct)
    %res=['nRules-', int2str(size(ruleStruct.rules,1))];
    res='';
end




