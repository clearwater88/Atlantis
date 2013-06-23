function [res] = getProbMapPixels(ruleId,slot,cellCentre,probMapStruct,imSize,angleDisc)
    offset = probMapStruct.offset{ruleId}(slot,:);
    covar = probMapStruct.cov{ruleId}(:,:,slot);
    vonM = probMapStruct.vonM{ruleId}(1);
    
    centreUse = cellCentre+offset;
    
    if (probMapStruct.strat == 1)
        angle = centreUse(3);
        rotMat = [cos(angle), sin(angle); -sin(angle), cos(angle)];
        centreUse(1:2) = (rotMat*offset(1:2)')' + cellCentre(1:2);
        covar = rotMat*covar*rotMat';
    end
    
    xLower = max(1,floor(centreUse(1)-3*sqrt(covar(1,1))));
    xUpper = min(imSize(1),ceil(centreUse(1)+3*sqrt(covar(1,1))));
    
    yLower = max(1,floor(centreUse(2)-3*sqrt(covar(2,2))));
    yUpper = min(imSize(2),ceil(centreUse(2)+3*sqrt(covar(2,2))));
    
    [x2,y2] = ndgrid(xLower:xUpper,yLower:yUpper);
    
    tempProb = zeros([imSize(1),imSize(2)]);
    inds = sub2ind(size(tempProb),x2(:),y2(:));
    
    tempProb(inds) = mvnpdf([x2(:),y2(:)],centreUse(1:2),covar(1:2,1:2));
    
    angleRange = angleDisc(1):angleDisc(2):angleDisc(3)-0.0001;
    probVon = exp(vonM*cos(angleRange-centreUse(3)));
    probVon = reshape(probVon,[1,1,numel(probVon)]);
    
    res = bsxfun(@times,tempProb,probVon);
    res = res/sum(res(:));

end

