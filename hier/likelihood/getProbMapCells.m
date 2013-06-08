function [res,resPixels] = getProbMapCells(ruleId,slot,cellCentre,probMapStruct,imSize,angleDisc,locsUse,cellDim)
    % prob map in cells, [imSize x num angles]. Num angles steps in
    % angleDisc.
    % returns prob maps according to order in poseCellLocs
    resPixels = getProbMapPixels(ruleId,slot,cellCentre,probMapStruct,imSize,angleDisc);

    res= zeros(size(locsUse,1),1);
    for (i=1:size(locsUse,1))
        loc = locsUse(i,:);
        
        mapXY = resPixels(loc(1)-(cellDim(1)-1)/2:loc(1)+(cellDim(1)-1)/2, ...
                          loc(2)-(cellDim(2)-1)/2:loc(2)+(cellDim(2)-1)/2, ...
                          :);
        sumXY = sum(sum(mapXY,1),2);
        sumXY = sumXY(:);
        lowerAngle = loc(3)-cellDim(3)/2;
        indStart = find(angleDisc(1):angleDisc(2):angleDisc(3) >= lowerAngle,1,'first');
        nAngleBins = cellDim(3)/angleDisc(2);
        
        temp = 0;
        for (j=0:nAngleBins-1)
           indUse = mod(indStart-1+j,numel(sumXY))+1;
           temp=temp+sumXY(indUse);
        end
        res(i) = temp;
    end
    res = res/sum(res);
end

