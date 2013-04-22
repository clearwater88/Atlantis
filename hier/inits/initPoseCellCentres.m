%centre of pose cells of each type
function cellParams = initPoseCellCentres(imSize)
    
    imSize = [imSize,2*pi]; % append range of angles in pose space
    
    %pose cell size specification. Make odd so centre is unambiguous
    cellDims(1,:) = [19,19,pi];
    cellDims(2,:) = [9,9,pi];
    
    %cellStrides(1,:) = [10,10,pi/4];
    %cellStrides(2,:) = [5,5,pi/8]; 
    
    cellStrides = cellDims;
    
    for (i=1:size(cellDims,1))
        temp = 1:cellStrides(i,1):(imSize(1)+1)-cellDims(i,1);
        temp2 = 1:cellStrides(i,2):(imSize(2)+1)-cellDims(i,2);
        temp3 = -pi:cellStrides(i,3):pi-0.0000001; % angle starts from -pi
        [temp,temp2,temp3] = meshgrid(temp,temp2,temp3);
        cellCentres{i} = [temp(:),temp2(:),temp3(:)]; 
        % re-centre
        cellCentres{i}(:,1:2) = bsxfun(@plus,cellCentres{i}(:,1:2),((cellDims(i,1:2))-1)/2);
        cellCentres{i}(:,3) = mod(bsxfun(@plus,cellCentres{i}(:,3),cellDims(i,3)/2),2*pi)-pi;
    end

    cellParams.centres = cellCentres;
    cellParams.dims = cellDims;
    cellParams.strides = cellStrides;
    
end

