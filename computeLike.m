function [likeSingle] = computeLike(params,data,qParts,gtBrick,nStart,nEnd)
    % likeSingle = 0 also used to mean undefined. Because we're just using these for
    % sums

    imSize = [size(data,1), size(data,2)];
    
    maxParts = size(gtBrick,3);
    
    
    likeSingle = zeros([nEnd-nStart+1,params.nParts,maxParts,imSize]);

    for (i=nStart:nEnd)
        dataTemp = data(:,:,i);
        
        for (p=1:params.nParts)
            
            bricksUse = reshape(gtBrick(i,p,:,:),[size(gtBrick,3),size(gtBrick,4)]);
            pSizeUse = params.partSizes(p,:);
            qPartUse = qParts{p};

            for (n=1:maxParts)
                br = bricksUse(n,:);
                if(br(1) == -1) continue; end;
                
                yStart = br(1)-pSizeUse(1); yEnd = br(1)+pSizeUse(1);
                xStart = br(2)-pSizeUse(2); xEnd = br(2)+pSizeUse(2);
                
                pts = meshgridRaster(yStart:yEnd,xStart:xEnd);
                [rotPts,~,origPtsInd] = rotatePts(pts,br(1:2),br(3),0);
                
                rotPtsInd = (rotPts(:,2)-1)*imSize(1)+rotPts(:,1);
                
                qUse = qPartUse(origPtsInd);
                dataUse = dataTemp(rotPtsInd);
                ent = (qUse.^dataUse).*((1-qUse).^(1-dataUse));
                
%                 figure(1);
%                 imshow(squeeze(likeSingle(i,p,n,:,:)));
                
                likeSingle(i,p,n,rotPtsInd) = ent;
                
%                 figure(2);
%                 imshow(squeeze(likeSingle(i,p,n,:,:)));
%                 pause
            end
        end
    end
end

