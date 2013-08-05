function viewHeatMap(sOn,probOn,cellParams,imSize,figNum)

    if (nargin < 5)
        figNum = 1000;
    end
    
    nTypes = numel(cellParams.coords);    
    
    maxAngle = -1;
    nCoordsInds = zeros(nTypes,3);
    for (n=1:nTypes)
        nCoordsInds(n,:) = max(cellParams.coords{n},[],1);
        maxAngle = max(maxAngle,max(cellParams.coords{n}(:,3)));
    end
    maxIm = max(cellParams.coordsSize,[],1);
    
    ims = {};
    
    for (n=1:nTypes)
        probOnType = reshape(probOn{n}, nCoordsInds(n,:));
        nAg = nCoordsInds(n,3);
        normUse = max(probOnType(:));
        
%         ct = (n-1)*nAg+1;
        
                    
            % zero out active bricks
%             centre = cellParams.centres{n}(sOn(2,sOn(1,:)==n),:);
%             centreInds = sub2ind(imSize(1:2),centre(:,1),centre(:,2));
        centre = cellParams.coords{n}(sOn(2,sOn(1,:)==n),:);
        centreInds = sub2ind(cellParams.coordsSize(n,1:2),centre(:,1),centre(:,2));
        
        for (ag=1:nAg)
            prob = probOnType(:,:,ag); prob = prob(:);
%             maskLayer = zeros(imSize);
            maskLayer = zeros(cellParams.coordsSize(n,1:2));
            centreAgInds = abs(bsxfun(@minus,centre(:,3),ag))< 0.001;
            centreAg = centreInds(centreAgInds);
            
            maskLayer(centreAg) = 1;
            
            % take advantage of raster order for angles
%             centres = cellParams.centres{n}(1:numel(prob),1:2);
%             centreInds = sub2ind(imSize,centres(:,1),centres(:,2));
            
            centres = cellParams.coords{n}(1:numel(prob),1:2);
            centreIndsProb = sub2ind(cellParams.coordsSize(n,1:2),centres(:,1),centres(:,2));
            
%             temp = zeros(imSize(1:2));
            temp = zeros(cellParams.coordsSize(n,1:2));
            temp(centreIndsProb) = prob/normUse;
            temp = repmat(temp,[1,1,3]);
            temp = bsxfun(@times,1-maskLayer,temp);
            tempLayer = temp(:,:,1);
            tempLayer(maskLayer==1) = 1;
            temp(:,:,1) = tempLayer;
            
%             temp(:,:,1) = maskLayer;
            
%             figure(figNum);
%             subplot(nTypes,maxAngle,ct); imagesc(temp,[0,1]); axis off;

            ims{end+1} = imresize(temp,[maxIm(1:2)],'nearest');
%             ct=ct+1;
        end
    end
    figure(figNum);
    imshowFull(makeCollage(ims,[nTypes,nAg])); 
end

