function [likeSingle] = computeLike(params,data,qParts,gtBrick,nStart,nEnd)
    % 0 also used to mean undefined. Because we're just using these for
    % sums

    imSize = [size(data,1), size(data,2)];
    
    maxParts = size(gtBrick,3);
    
    
    likeSingle = zeros([nEnd-nStart+1,params.nParts,maxParts,imSize]);

    for (i=nStart:nEnd)
        for (p=1:params.nParts)
            
            bricksUse = squeeze(gtBrick(i,p,:,:));
            pSizeUse = params.partSizes(p,:);
            qPartUse = qParts{p};

            for (n=1:maxParts)
                br = bricksUse(n,:);
                if(br(1) == -1) continue; end;
                
                %yStart = max(1,br(1)-pSizeUse(1)); yStartDiff = yStart-(br(1)-pSizeUse(1));
                %yEnd = min(imSize(1),br(1)+pSizeUse(1)); yEndDiff = br(1)+pSizeUse(1)-yEnd;
                
                %xStart = max(1,br(2)-pSizeUse(2)); xStartDiff = xStart-(br(2)-pSizeUse(2));
                %xEnd = min(imSize(2),br(2)+pSizeUse(2)); xEndDiff = br(2)+pSizeUse(2)-xEnd;
                
                yStart = br(1)-pSizeUse(1); yEnd = br(1)+pSizeUse(1);
                xStart = br(2)-pSizeUse(2); xEnd = br(2)+pSizeUse(2);
                
                qUse = qPartUse;
                dataUse = data(yStart:yEnd, xStart:xEnd, i);
                ent = (qUse.^dataUse).*((1-qUse).^(1-dataUse));
                
                temp = zeros(imSize); temp(yStart:yEnd, xStart:xEnd) = ent;
                likeSingle(i,p,n,:,:) = temp;
                
            end
        end
    end
end

