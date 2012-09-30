function [im] = projectRect(im,y,x,rot,s,xAx,yAx)

%     rotMat = [cos(rot), -sin(rot); sin(rot), cos(rot)];
%     
%     xT = [x-xAx, x-xAx, x+xAx, x+xAx];
%     yT = [y-yAx, y+yAx, y+yAx, y-yAx];
%     
%     pts = rotMat*[yT-y;xT-x];
%     pts(1,:) = round(pts(1,:) + y);
%     pts(2,:) = round(pts(2,:) + x);
%     
%     im = im | poly2mask(pts(2,:),pts(1,:),size(im,1),size(im,2));
%     
    backRot = [cos(rot), -sin(rot); sin(rot), cos(rot)];
    [yPt,xPt] = meshgrid(1:size(im,1),1:size(im,2));
    
    oldPts = [yPt(:),xPt(:)];
    pts = bsxfun(@plus,bsxfun(@minus,oldPts,[y,x])*backRot,[y,x]);
    
    badInds = (abs(pts(:,1) - y) > yAx) | ...
              (abs(pts(:,2) - x) > xAx);
    
    oldPts(badInds,:) = [];
    oldPts = oldPts(:,2)*size(im,1)+oldPts(:,1);
    
    oldPts(oldPts<0) = [];
    oldPts(oldPts>numel(im)) = [];
    
    im(oldPts) = 1;

end

