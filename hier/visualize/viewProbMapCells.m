function viewProbMapCells(poseCellCentres,probMapCells, figNum)
    % poseCellLocs: must belong to type of probMapCells

    if (nargin < 3) figNum = 3; end
    
    x = unique(poseCellCentres(:,1));
    y = unique(poseCellCentres(:,2));
    angles = unique(poseCellCentres(:,3));
    
    res = zeros(numel(x),numel(y),numel(angles));

    for (i=1:numel(probMapCells))
       xInd = x==poseCellCentres(i,1); 
       yInd = y==poseCellCentres(i,2); 
       angleInd = angles==poseCellCentres(i,3);       
       res(xInd,yInd,angleInd) = probMapCells(i);       
    end
    
    figure(figNum);
    for (i=1:size(res,3))
       imshow(res(:,:,i));  colormap(gray);
       a=res(:,:,i);
       display(max(a(:)));
       pause;
    end
end

