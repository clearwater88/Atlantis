function [res] = getProbMapPixels(ruleId,slot,cellCentre,probMapStruct,imSize,angleDisc)
    offset = probMapStruct.offset{ruleId}(slot,:);
    covar = probMapStruct.cov{ruleId}(:,:,slot);
    centreUse = cellCentre+offset;
    
    if (probMapStruct.strat == 1)
        angle = centreUse(3);
        rotMat = [cos(angle), sin(angle); -sin(angle), cos(angle)];
        centreUse = (rotMat*offset(1:2)')' + cellCentre(1:2);
        covar(1:2,1:2) = rotMat*covar(1:2,1:2)*rotMat';
        
        centreUse(:,3) = angle;
    end
    
    xLower = max(1,floor(centreUse(1)-4*sqrt(covar(1,1))));
    xUpper = min(imSize(1),ceil(centreUse(1)+4*sqrt(covar(1,1))));
    
    yLower = max(1,floor(centreUse(2)-4*sqrt(covar(2,2))));
    yUpper = min(imSize(2),ceil(centreUse(2)+4*sqrt(covar(2,2))));

    angleRange = -pi+angleDisc(1):angleDisc(2):angleDisc(3)+pi;

    
    tempProb = zeros([imSize(1),imSize(2),numel(angleRange)]);
    [x2,y2,angle2] = ndgrid(xLower:xUpper,yLower:yUpper,angleRange);
    angle2 = angle2(:);
    inds = sub2ind(size(tempProb),x2(:),y2(:),round(1+(angle2-(angleDisc(1)-pi))/angleDisc(2)));

    tempProb(inds) = mvnpdf([x2(:),y2(:),angle2(:)],centreUse,covar);

    period = 2*pi/angleDisc(2); % must be an integer
    res = zeros([imSize(1),imSize(2),2*pi/angleDisc(2)]);
    for (i=1:size(tempProb,3))
        res(:,:,mod(i,period)+1) = res(:,:,mod(i,period)+1) + tempProb(:,:,i);
    end

    assert(~any(isnan(res(:)/sum(res(:)))));
    res = res/sum(res(:));
    
end

