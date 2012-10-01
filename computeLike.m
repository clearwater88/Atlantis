function res = computeLike(params,data,qParts,gtBrick)
    % Likelihood produces ZERO where undefined (not NaN). This is because
    % we'll be summing lielihood anyway, so 0 should be OK. Also, 0
    % likelihood means definitely cannoy explain pixel, which could be
    % semantically true, depending how you look at it.

    nImages = size(data,3);
    imSize = [size(data,1),size(data,2)];
    
    res = zeros([nImages,params.nParts,imSize]);
    
    for (i=1:nImages)
        for (p=1:params.nParts)
            
            bricksUse = gtBrick{i,p};
            pSizeUse = params.partSizes(p,:);
            qPartUse = qParts{p};
            ll = zeros(imSize);
            for (n=1:numel(bricksUse))
                br = bricksUse{n};
                
                yStart = max(1,br(1)-pSizeUse(1)); yStartDiff = yStart-(br(1)-pSizeUse(1));
                yEnd = min(imSize(1),br(1)+pSizeUse(1)); yEndDiff = br(1)+pSizeUse(1)-yEnd;
                
                xStart = max(1,br(2)-pSizeUse(2)); xStartDiff = xStart-(br(2)-pSizeUse(2));
                xEnd = min(imSize(2),br(2)+pSizeUse(2)); xEndDiff = br(2)+pSizeUse(2)-xEnd;
                
                qUse = qPartUse(yStartDiff+1:end-yEndDiff,xStartDiff+1:end-xEndDiff);
                
                dataUse = data(yStart:yEnd, xStart:xEnd, i);
                temp = (qUse.^dataUse).*((1-qUse).^(1-dataUse));
                ll(yStart:yEnd,xStart:xEnd) = ll(yStart:yEnd,xStart:xEnd) + temp;
                
            end
            res(i,p,:,:) = ll;
        end
    end
end

