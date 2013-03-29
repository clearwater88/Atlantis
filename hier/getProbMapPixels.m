function [res] = getProbMapPixels(ruleId,slot,cellCentre,probMapStruct,imSize,angleDisc)
    
    offset = probMapStruct.offset{ruleId}(slot,:);
    covar = probMapStruct.cov{ruleId}(:,:,slot);
    centreUse = cellCentre+offset;
    
    
    % consider over period of 3
    angleRange = angleDisc(1)-2*pi:angleDisc(2):angleDisc(3)+2*pi;
    
    %approximate locations of mass
    xLower = max(1,cellCentre(1)-4*covar(1,1));
    xUpper = min(imSize(1),cellCentre(1)+3*covar(1,1));
    
    yLower = max(1,cellCentre(2)-4*covar(2,2));
    yUpper = min(imSize(2),cellCentre(2)+3*covar(2,2));
    
    tempProb = zeros([imSize(1),imSize(2),numel(angleRange)]);
    [x2,y2,angle2] = ndgrid(xLower:xUpper,yLower:yUpper,angleRange);
    temp = mvnpdf([x2(:),y2(:),angle2(:)],centreUse,covar);
    
    inds = sub2ind(size(tempProb),x2(:),y2(:),round(1+(2*pi-angleDisc(1)+angle2(:))/angleDisc(2)));
    tempProb(inds) = temp;
    
    % exact computation
%     [x,y,angle] = ndgrid(1:imSize(1),1:imSize(2),angleRange);
%     tempProb = mvnpdf([x(:),y(:),angle(:)],centreUse,covar);
%     tempProb = reshape(tempProb,[imSize,numel(angleRange)]);
    
    period = 2*pi/angleDisc(2); % must be an integer
    res = zeros([imSize(1),imSize(2),2*pi/angleDisc(2)]);
    for (i=1:size(tempProb,3))
       res(:,:,mod(i,period)+1) = res(:,:,mod(i,period)+1) + tempProb(:,:,i);
    end
    res = res/sum(res(:));
    
end

