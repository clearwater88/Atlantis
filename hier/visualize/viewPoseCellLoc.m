function viewPoseCellLoc(cellId,poseCellLocs,figNum)

    if (nargin < 3) figNum = 3; end

    
    x = unique(poseCellLocs(:,1));
    y = unique(poseCellLocs(:,2));
    angles = unique(poseCellLocs(:,3));
    
    % spatial XY only
    res = zeros(numel(x),numel(y));
    
    xInd = x==poseCellLocs(cellId,1);
    yInd = y==poseCellLocs(cellId,2);
    
    res(xInd,yInd) = 1;
    
    figure(figNum);
    imagesc(res); colormap(gray);
    
end

