function viewHeatMap(probOn,cellParams)

    nTypes = numel(cellParams.coords);
    nCoordsInds = zeros(nTypes,3);
    for (n=1:nTypes)
       nCoordsInds(n,:) = max(cellParams.coords{n},[],1);   
    end
    maxAngle = max(nCoordsInds(:,3));
    
    for (n=1:nTypes)
       probOnType = reshape(probOn{n}, nCoordsInds(n,:));
       nAg = nCoordsInds(n,3);
       
       ct = (n-1)*nAg+1;
       for (ag=1:nAg)
           subplot(nTypes,maxAngle,ct); imagescGray(probOnType(:,:,ag));
           ct=ct+1;
       end
    end
end

