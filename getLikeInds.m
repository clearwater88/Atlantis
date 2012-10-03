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
               
                yStart = br(1)-pSizeUse(1); yEnd = br(1)+pSizeUse(1);
                xStart = br(2)-pSizeUse(2); xEnd = br(2)+pSizeUse(2);
               
                pts = meshgridRaster(yStart:yEnd,xStart:xEnd);
                [rotPts,~,origPtsInd] = rotatePts(pts,br(1:2),br(3),0);
                rotPtsInd = (rotPts(:,2)-1)*imSize(1)+rotPts(:,1);
                
                likeInds(n,p,mp,rotPtsInd) = origPtsInd;
                
           end
       end
        
    end

    likeInds = permute(likeInds,[4,5,2,3,1]);
    
end

