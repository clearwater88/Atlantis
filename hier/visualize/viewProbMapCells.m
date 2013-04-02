function viewProbMapCells(poseCellLocs,probMapCells, figNum)
    % poseCellLocs: must belong to type of probMapCells

    if (nargin < 3) figNum = 3; end
    
    x = unique(poseCellLocs(:,1));
    y = unique(poseCellLocs(:,2));
    angles = unique(poseCellLocs(:,3));
    
    res = zeros(numel(x),numel(y),numel(angles));

    for (i=1:numel(probMapCells))
       xInd = x==poseCellLocs(i,1); 
       yInd = y==poseCellLocs(i,2); 
       angleInd = angles==poseCellLocs(i,3);       
       res(xInd,yInd,angleInd) = probMapCells(i);       
    end
    
    figure(figNum);
    for (i=1:size(res,3))
       imagesc(res(:,:,i));  colormap(gray);
       a=res(:,:,i);
       display(max(a(:)));
       pause;
    end
end

