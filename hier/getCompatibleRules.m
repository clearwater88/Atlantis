function [mask] = getCompatibleRules(brickId,children,bricks,ruleStruct)
    % returns mask that can be used on ruleStruct

    type = bricks(2,brickId);
    % child entry may be 0 to specify not selected yet
    % no ability to say "this slot is blank"
    
    % zeros are sentinel to indicate not used yet
    childTypes = zeros(1,numel(children));
    validChildren = children~=0;
    childTypes(validChildren) = bricks(2,children(validChildren));
    
    % no valid children? then only need to look at parent of rule
    if (isempty(childTypes(validChildren)))
        mask = ones(size(ruleStruct.parents,1),1);
    else
        ruleParts = ruleStruct.children(:,validChildren);
        tic
        %mask = ismember(ruleParts,childTypes(validChildren),'rows');
        mask = jIsMemberRows(ruleParts,childTypes(validChildren));        
    end
    mask = mask & (ruleStruct.parents==type);
end

