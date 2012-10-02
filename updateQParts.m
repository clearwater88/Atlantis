function qParts = updateQParts(params,data,likeSingle,gtBrick,qParts)
    % likeSingle: [nImages,nParts,maxParts,imSize]

    nImages = size(data,3);
    imSize = [size(data,1),size(data,2)];
    nParts = params.nParts;
    maxParts = size(likeSingle,3);
    
    %sumLikeAll = squeeze(sum(sum(likeSingle,2),3));
    
    corners = getCorners(params,gtBrick);
    
    totalLike = sum(sum(likeSingle,2),3);
    % [nImage,nParts,maxPartPer,imSize]
    likePartDiff = bsxfun(@minus,totalLike,likeSingle);
    
    tic
    for (p=1:nParts)
        
        counter = 1;
        stackedParts = zeros([2*params.partSizes(p,:)+1,maxParts*nImages]);
        stackedData = zeros([2*params.partSizes(p,:)+1,maxParts*nImages]);
        for (mp=1:maxParts)
            temp = squeeze(likePartDiff(:,p,mp,:,:));
            cornerUse = squeeze(corners(:,p,mp,:));
            for (n=1:nImages)
                tempN = squeeze(temp(n,:,:));
                cornerN = cornerUse(n,:);
                
                % sentinel condition
                if(cornerN(1) > cornerN(2)) continue; end;
                
                stackedParts(:,:,counter) = tempN(cornerN(1):cornerN(2), ...
                                                  cornerN(3):cornerN(4));
                stackedData(:,:,counter) = data(cornerN(1):cornerN(2), ...
                                                cornerN(3):cornerN(4),n);
                counter = counter + 1;
            end
        end
        % delete unused stuff
        stackedParts(:,:,counter:end) = [];
        stackedData(:,:,counter:end) = [];
        qParts{p} = solveQ(params,stackedParts,stackedData);
    end
    toc
end

function res = solveQ(params,stackedParts,stackedData)
    origSize = size(stackedParts);
    
    stackedParts = reshape(stackedParts,[origSize(1)*origSize(2),origSize(3)]);
    stackedData = reshape(stackedData,[origSize(1)*origSize(2),origSize(3)]);

    q = [0:params.qFidel:1];
    q = reshape(q,[1,1,numel(q)]);

    y0 = sum(bsxfun(@times,(1./(bsxfun(@plus,1-q,stackedParts))),(1-stackedData)),2);
    y1 = sum(bsxfun(@times,(1./(bsxfun(@plus,q,stackedParts))),stackedData),2);
    
    diff = abs(y0-y1);
    [~,inds] = min(diff,[],3);
    q = reshape(q,[numel(q),1]);
    res = q(inds);
    res = reshape(res,[origSize(1),origSize(2)]);
 
end