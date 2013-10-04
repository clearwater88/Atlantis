function [res] = getProbMapPixels(offset,covar,vonM,cellCentre,probMapStruct,imSize,angleRange)
    % returns the probability a cell with a particular centre, and using a particular rule in a particular slot,
    % points to a brick of a particular pose

    if (probMapStruct.strat == 1)
        centreUse(3) = cellCentre(3)+offset(3);
        rotMat = [cos(centreUse(3)), sin(centreUse(3)); -sin(centreUse(3)), cos(centreUse(3))];
        centreUse(1:2) = (rotMat*offset(1:2)')' + cellCentre(1:2);

        covar = rotMat*covar*rotMat';
    else
        centreUse = cellCentre+offset;
    end
    
    xLower = max(1,floor(centreUse(1)-3*sqrt(covar(1,1))));
    xUpper = min(imSize(1),ceil(centreUse(1)+3*sqrt(covar(1,1))));
    
    yLower = max(1,floor(centreUse(2)-3*sqrt(covar(2,2))));
    yUpper = min(imSize(2),ceil(centreUse(2)+3*sqrt(covar(2,2))));
    
    [x2,y2] = ndgrid(xLower:xUpper,yLower:yUpper);
    
    tempProb = zeros(imSize);
    inds = sub2ind(imSize,x2(:),y2(:));
    
    tempProb(inds) = mvnpdf([x2(:),y2(:)],centreUse(1:2),covar(1:2,1:2));
    
    probVon = exp(vonM*cos(angleRange-centreUse(3)));
    probVon = probVon/sum(probVon);
    probVon = reshape(probVon,[1,1,numel(probVon)]);
    
    res = bsxfun(@times,tempProb,probVon);
    res = res/sum(res(:));

end

