%centre of pose cells of each type
function cellParams = initPoseCellCentres(imSize)
    
    imSize = [imSize,2*pi]; % append range of angles in pose space
    
    %pose cell size specification. Make odd so centre is unambiguous
    cellDims(1,:) = [17,17,pi];
    cellDims(2,:) = [13,13,pi];
    cellDims(3,:) = [9,9,pi];
    
    cellStrides(1,:) = [9,9,pi/2];
    cellStrides(2,:) = [7,7,pi/2];
    cellStrides(3,:) = [5,5,pi/2]; 
    
    %cellStrides = cellDims;
    
    nTypes = size(cellDims,1);
    cellCentres = cell(nTypes,1);
    cellBoundaries = cell(nTypes,1);
    
    
    for (i=1:nTypes)
        temp = 1:cellStrides(i,1):(imSize(1)+1)-cellDims(i,1);
        temp2 = 1:cellStrides(i,2):(imSize(2)+1)-cellDims(i,2);
        temp3 = -pi:cellStrides(i,3):pi-0.0000001; % angle starts from -pi
        [temp,temp2,temp3] = meshgrid(temp,temp2,temp3);
        cellCentres{i} = [temp(:),temp2(:),temp3(:)]; 
        % re-centre
        cellCentres{i}(:,1:2) = bsxfun(@plus,cellCentres{i}(:,1:2),((cellDims(i,1:2))-1)/2);
        cellCentres{i}(:,3) = mod(bsxfun(@plus,cellCentres{i}(:,3),cellDims(i,3)/2),2*pi)-pi;

        % # 2 x cells
        lowCell = bsxfun(@minus,cellCentres{i}(:,1:2),(cellDims(i,1:2)-1)/2)';
        lowCell=reshape(lowCell,[size(lowCell,1),1,size(lowCell,2)]);
        angleLow = cellCentres{i}(:,3)-cellDims(i,3)/2;
        angleLow = reshape(angleLow,[1,1,numel(angleLow)]);
        
        
        highCell = bsxfun(@plus,cellCentres{i}(:,1:2),(cellDims(i,1:2)-1)/2)';
        highCell=reshape(highCell,[size(highCell,1),1,size(highCell,2)]);
        angleHigh = cellCentres{i}(:,3)+cellDims(i,3)/2;
        angleHigh = reshape(angleHigh,[1,1,numel(angleHigh)]);
            
    
        cellBoundaries{i} = cat(2,lowCell,highCell);
        cellBoundaries{i}(3,:,:) = cat(2,angleLow,angleHigh);
    end

    cellParams.centres = cellCentres;
    cellParams.dims = cellDims;
    cellParams.strides = cellStrides;
    cellParams.nTypes = nTypes;
    cellParams.boundaries = cellBoundaries;
end

