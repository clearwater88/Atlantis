%centre of pose cells of each type
function cellParams = initPoseCellCentres(imSize,sizes)
    
    imSize = [imSize,2*pi]; % append range of angles in pose space
    
    % Make odd so centre is unambiguous
    cellDims(1,:) = [15,15,pi/4];
    cellDims(2,:) = [15,15,pi/4];
    cellDims(3,:) = [15,15,pi/4];
    cellDims(4,:) = [15,15,pi/4];
    
    strides(1,:) = [16,16,pi/8];
    strides(2,:) = [16,16,pi/8];
    strides(3,:) = [16,16,pi/8];
    strides(4,:) = [16,16,pi/8];
    
    %cellStrides = cellDims;
    
    nTypes = size(cellDims,1);
    cellCentres = cell(nTypes,1);
    cellBoundaries = cell(nTypes,1);
    coords = cell(nTypes,1);
    origins = zeros(nTypes,3);
    coordsSize = zeros([nTypes,3]);
    
    for (i=1:nTypes)
        sz = sizes(i,:);
        
        cellCentres{i} = getLocsUse(strides(i,:), cellDims(i,:), sz, imSize);
        origins(i,:) = cellCentres{i}(1,:);
        
        coords{i} = round(centre2CellFrame(cellCentres{i},strides(i,:),origins(i,:)));
        
%         coords{i} =  bsxfun(@plus, ...
%                             bsxfun(@rdivide, ...
%                                    bsxfun(@minus, ...
%                                           cellCentres{i}, ...
%                                           origin), ...
%                                    strides(i,:)), ...
%                             [1,1,1]);
        
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
        
        coordsSize(i,1:2) = max(coords{i}(:,1:2));
        coordsSize(i,3) = numel(unique(coords{i}(:,3)));
    end

    cellParams.centres = cellCentres;
    cellParams.dims = cellDims;
    cellParams.strides = strides;
    cellParams.nTypes = nTypes;
    cellParams.centreBoundaries = cellBoundaries;
    cellParams.coords = coords;
    cellParams.origins = origins;
    cellParams.toString = @toString;
    cellParams.coordsSize = coordsSize;
end

function res = toString(cellParams)
    res = ['cell-dims'];
    for (i=1:size(cellParams.dims,1))
        res = [res, int2str(cellParams.dims(i,1))];
        if (i ~= size(cellParams.dims,1))
            res = [res,'_'];
        end
    end
    res = [res,'-strides'];
    for (i=1:size(cellParams.strides,1))
        res = [res, int2str(cellParams.strides(i,1))];
        if (i ~= size(cellParams.strides,1))
            res = [res,'_'];
        end
    end
end

