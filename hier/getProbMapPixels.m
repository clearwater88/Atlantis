function [res] = getProbMapPixels(ruleId,slot,cellCentre,probMapStruct,imSize,angleDisc)
    
    offset = probMapStruct.offset{ruleId}(slot,:);
    covar = probMapStruct.cov{ruleId}(:,:,slot);
    centreUse = cellCentre+offset;
    
    % consider over period of 5
    angleRange = angleDisc(1)-4*pi:angleDisc(2):angleDisc(3)+4*pi;
    
    [x,y,angle] = ndgrid(1:imSize(1),1:imSize(2),angleRange);
    
    temp = mvnpdf([x(:),y(:),angle(:)],centreUse,covar);
    temp = reshape(temp,[imSize,numel(angleRange)]);
    
    period = 2*pi/angleDisc(2); % must be an integer
    res = zeros([size(temp,1),size(temp,2),2*pi/angleDisc(2)]);
    
    for (i=1:size(temp,3))
       res(:,:,mod(i,period)+1) = res(:,:,mod(i,period)+1) + temp(:,:,i);
    end
    res = res/sum(res(:));
end

