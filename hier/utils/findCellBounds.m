function [res] = findCellBounds(cellType,cellLocIdx,cellParams)
    centre = cellParams.centres{cellType}(cellLocIdx,:);
    dims = cellParams.dims(cellType,:);
    
    res = [centre(1:2)-(dims(1:2)-1)/2;centre(1:2)+(dims(1:2)-1)/2];
    res(end+1,:) = [centre(3)-dims(3)/2,centre(3)+dims(3)/2];
end

