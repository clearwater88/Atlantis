function qParts = learnParams(params,data,gtBrick)

    nImages = size(data,3);
    
    qParts = cell(params.nParts,1);
    %% initialize appearance params
    for (i=1:params.nParts)
        qParts{i} = 0.3+0.4*rand(2*params.partSizes(i,:)+1);
    end
        

    nStart = 1;
    
    nEnd =nImages;
    tic
    for (it=1:params.qIter)
        likeSingle = computeLike(params,data,qParts,gtBrick,nStart,nEnd);
        qParts = updateQParts(params,data,likeSingle,gtBrick,qParts);
        %figure(1); imshow(qParts{1});
        %figure(2); imshow(qParts{2});
        %pause
    end
    toc
    
end