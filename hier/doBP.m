function doBP(testData,posesStruct,likePxIdxCells,cellMapStruct,cellParams,params,ruleStruct,templateStruct)

    nTypes = numel(cellParams.coords);
    nBricksType = zeros(nTypes,1);
    for (n=1:nTypes)
       nBricksType(n) = size(cellParams.coords{n},1);
    end

    % allocate space for messages
    uFb1ToSb = zeros(sum(nBricksType),1); %store sb = 0
    % uSbToFb2 = uFb1ToSb
    uFb2ToRb = zeros(sum(nBricksType),size(ruleStruct.rules,1)); % inefficient space. Storing ALL rules for each brick. This should not be memory bottlebeck.
    % uRbToFb3 = uFb2ToRb
    uFb3ToGbk = zeros(sum(nBricksType),size(ruleStruct.rules,2));
    
end