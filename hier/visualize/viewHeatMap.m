function viewHeatMap(sOn,probOn,cellParams,imSize,figNum)

    if (nargin < 5)
        figNum = 1000;
    end
    
    nTypes = numel(cellParams.coords);    
    
    nCoordsInds = zeros(nTypes,3);
    for (n=1:nTypes)
        nCoordsInds(n,:) = max(cellParams.coords{n},[],1);
    end
    maxAngle = max(nCoordsInds(:,3));
    
    figure(figNum);
    for (n=1:nTypes)
        probOnType = reshape(probOn{n}, nCoordsInds(n,:));
        nAg = nCoordsInds(n,3);
        normUse = max(probOnType(:));
        
        ct = (n-1)*nAg+1;
        for (ag=1:nAg)
            prob = probOnType(:,:,ag); prob = prob(:);
            maskLayer = zeros(imSize);
            
            % zero out active bricks
            centre = cellParams.centres{n}(sOn(1,:) == n,:);
            centreInds = sub2ind(imSize(1:2),centre(:,1),centre(:,2));
            maskLayer(centreInds) = 1;
            
            % take advantage of raster order for angles
            centres = cellParams.centres{n}(1:numel(prob),1:2);
            centreInds = sub2ind(imSize,centres(:,1),centres(:,2));
            
            temp = zeros(imSize(1:2));
            temp(centreInds) = prob/normUse;
            temp = repmat(temp,[1,1,3]);
            temp(:,:,2:3) = bsxfun(@times,1-maskLayer,temp(:,:,2:3));
            
            subplot(nTypes,maxAngle,ct); imshow(temp);
            ct=ct+1;
        end
    end
end

