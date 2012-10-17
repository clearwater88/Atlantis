function [likeInds] = getLikeInds(params,data,gtBrick,nStart,nEnd)
    

    imSize = [size(data,1), size(data,2)];
    
    maxParts = size(gtBrick,3);
    
    
    likeInds = zeros([nEnd-nStart+1,params.nParts,maxParts,imSize]);

    for (n=nStart:nEnd)
       for (p=1:params.nParts)
           bricksUse = reshape(gtBrick(n,p,:,:),[size(gtBrick,3),size(gtBrick,4)]);
           pSizeUse = params.partSizes(p,:);
           
           for (mp=1:maxParts)
               br = bricksUse(mp,:);
               if(br(1) == -1) continue; end;
                [rotPtsInd,~,origPtsInd] = doGetLikeInds(br(1),br(2),br(3),br(4),pSizeUse,imSize,0);
                likeInds(n,p,mp,rotPtsInd) = origPtsInd; 
           end
       end
    end

    likeInds = permute(likeInds,[4,5,2,3,1]);
    
end

