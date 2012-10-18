function stackedDataAllP = getStackedData(params,data,gtBrick)

    nImages = size(data,3);
    imSize = [size(data,1),size(data,2)];
    nParts = params.nParts;
    maxParts = size(gtBrick,3);
    
    stackedDataAllP = cell(params.nParts,1);
    for (p=1:nParts)
        counter = 1;
        pSizeUse = params.partSizes(p,:);
        stackedData = zeros([2*params.partSizes(p,:)+1,maxParts*nImages]);
        for (mp=1:maxParts)
            % [nImages,imSize]
            
            for (n=1:nImages)
                dataN = data(:,:,n);
                
                br = gtBrick(n,p,mp,:); br = reshape(br,[1,numel(br)]);
                if(br(1) == -1) continue; end;
                
                yStart = br(1)-pSizeUse(1); yEnd = br(1)+pSizeUse(1);
                xStart = br(2)-pSizeUse(2); xEnd = br(2)+pSizeUse(2);
                pts = meshgridRaster(yStart:yEnd,xStart:xEnd);
                
                imPts = rotatePts(pts,br(1:2),br(3),br(4),1,imSize);
                imPtsInd = imSize(1)*(imPts(:,2)-1)+imPts(:,1);
                stackedData(:,:,counter) = reshape(dataN(imPtsInd),2*[pSizeUse(1),pSizeUse(2)]+1);
                
                counter = counter+1;
            end
        end
        stackedData(:,:,counter:end) = [];
        stackedDataAllP{p} = stackedData;
    end
end

