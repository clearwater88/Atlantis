function qParts = updateQParts(params,stackedData,partInds,loc,likeSingle,data)
    % likeSingle: [nImages,nParts,maxParts,imSize]

    
    %sumLikeAll = squeeze(sum(sum(likeSingle,2),3));
    
    totalLike = sum(sum(likeSingle,2),3);
    % [nImage,nParts,maxPartPer,imSize]
    likePartDiff = bsxfun(@minus,totalLike,likeSingle);
    qParts = cell(params.nParts,1);
    
    for (p=1:params.nParts)
        partIndUse = partInds{p};
        locUse = loc{p};
        
        stackedParts = zeros(size(partIndUse));
        likePartDiffUse = likePartDiff(:,p,:,:,:);
        sh = size(likePartDiffUse); sh(2) = [];
        likePartDiffUse = reshape(likePartDiffUse,sh);
        
        for (c=1:size(partIndUse,3))
           temp = squeeze(likePartDiffUse(locUse(1,c),locUse(2,c),:,:));
           stackedParts(:,:,c) = temp(partIndUse(:,:,c));
        end
        qParts{p} = solveQ(params,stackedParts,stackedData{p});

    end
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