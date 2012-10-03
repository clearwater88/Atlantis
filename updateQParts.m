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

    stackedDataAllP = cell(params.nParts,1);
    for (p=1:nParts)
        counter = 1;
        pSizeUse = params.partSizes(p,:);
        stackedData = zeros([2*params.partSizes(p,:)+1,maxParts*nImages]);
        for (mp=1:maxParts)
            % [nImages,imSize]
            
            for (n=1:nImages)
                %tempN = likePartDiff(n,p,mp,:,:);
                %tempN = reshape(tempN,[size(tempN)]);
                dataN = data(:,:,n);
                
                br = gtBrick(n,p,mp,:); br = reshape(br,[1,numel(br)]);
                if(br(1) == -1) continue; end;
                
                yStart = br(1)-pSizeUse(1); yEnd = br(1)+pSizeUse(1);
                xStart = br(2)-pSizeUse(2); xEnd = br(2)+pSizeUse(2);
                pts = meshgridRaster(yStart:yEnd,xStart:xEnd);
                
                imPts = rotatePts(pts,br(1:2),br(3),1);
                imPtsInd = imSize(1)*(imPts(:,2)-1)+imPts(:,1);
                stackedData(:,:,counter) = reshape(dataN(imPtsInd),2*[pSizeUse(1),pSizeUse(2)]+1);
                
                counter = counter+1;
            end
        end
        stackedData(:,:,counter:end) = [];
        stackedDataAllP{p} = stackedData;
    end
    
    toc
    
    
%         counter = 1;
%         stackedParts = zeros([2*params.partSizes(p,:)+1,maxParts*nImages]);
%         stackedData = zeros([2*params.partSizes(p,:)+1,maxParts*nImages]);
%         for (mp=1:maxParts)
%             temp = squeeze(likePartDiff(:,p,mp,:,:));
%             cornerUse = squeeze(corners(:,p,mp,:));
%             for (n=1:nImages)
%                 tempN = squeeze(temp(n,:,:));
%                 cornerN = cornerUse(n,:);
%                 
%                 % sentinel condition
%                 if(cornerN(1) > cornerN(2)) continue; end;
%                 
%                 stackedParts(:,:,counter) = tempN(cornerN(1):cornerN(2), ...
%                                                   cornerN(3):cornerN(4));
%                 stackedData(:,:,counter) = data(cornerN(1):cornerN(2), ...
%                                                 cornerN(3):cornerN(4),n);
%                 counter = counter + 1;
%             end
%         end
%         % delete unused stuff
%         stackedParts(:,:,counter:end) = [];
%         stackedData(:,:,counter:end) = [];
%         qParts{p} = solveQ(params,stackedParts,stackedData);
%     end
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