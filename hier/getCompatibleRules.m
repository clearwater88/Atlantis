function [mask] = getCompatibleRules(brickId,slots,bricks,ruleStruct)
    % mask for valid rules

    type = bricks(2,brickId);
    % child entry may be 0 to specify not selected yet
    % no ability to say "this slot is blank"
    
    % zeros are sentinel to indicate not used yet
    childTypes = zeros(1,numel(slots));
    validChildren = slots~=0;
    childTypes(validChildren) = bricks(2,slots(validChildren));
    
    % no valid slots? then only need to look at parent of rule
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

