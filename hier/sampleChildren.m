function res = sampleChildren(parentLocInd,ruleId,slots,allProbMaps,bricks,ruleStruct)

    res = zeros(numel(slots),1);
    for (i=1:numel(slots))
        % access allProbMaps with probMap{ruleId,slot,loc index}
        probMap = allProbMaps{ruleId,slots(i),parentLocInd};
        res(i) = sampleChild(probMap);
    end
    
    for (i=1:numel(slots))
        chType = ruleStruct.children(ruleId,slots(i));
        
        childValid = any((bricks(1,:) == 1) & ... % brick on
            (bricks(2,:) == chType) & ... % brick is right type
            (bricks(3,:) == res(i))==1); % brick is in right location
        if(~childValid)
            res(i) = 0;
        end
    end

end

