function learnParams(params,data,gtBrick)

    imSize = [size(data,1),size(data,2)];

    
    qParts = cell(params.nParts,1);
    %% initialize appearance params
    for (i=1:params.nParts)
        qParts{i} = 0.4+0.2*rand(2*params.partSizes(i,:)+1);
    end
        
    tic
    likelihood = computeLike(params,data,qParts,gtBrick);
    toc
    
end