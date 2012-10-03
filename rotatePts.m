function [res,corresPts,corresPtsInd] = rotatePts(inPts,centre,rot,fillSource)
    % inPts: nPts x 2
    % centre: [1,2]
    % looks like counter clockwise rotation because y-axis points down
    % image

    % For coordinates in y-x format
    % this is really a backwarp
    rotBackMat = [cos(-rot), sin(-rot); -sin(-rot), cos(-rot)];
    rotForMat = [cos(rot),sin(rot); -sin(rot) cos(rot)];
    
    rotInPts = round(bsxfun(@plus,(rotForMat*bsxfun(@minus,inPts,centre)')',centre));
    if (fillSource == 1)        
        res = rotInPts;
        return;
    end
    
    minYX = min(rotInPts,[],1);
    maxYX = max(rotInPts,[],1);    
    
    [newY,newX] = meshgrid(minYX(1):maxYX(1),minYX(2):maxYX(2));
    
    res = [newY(:),newX(:)];
    corresPts = round(bsxfun(@plus,(rotBackMat*bsxfun(@minus,res,centre)')',centre));

    badPts = ~(ismember(corresPts(:,1),inPts(:,1)) & ...
               ismember(corresPts(:,2),inPts(:,2)));

    res(badPts,:) = [];
    corresPts(badPts,:) = [];
    
    [~,corresPtsInd] = ismember(corresPts,inPts,'rows');
    
%     im1 = zeros(15,15);
%     im1(sub2ind([15,15],inPts(:,1),inPts(:,2))) = 1;
%     
%     im2 = zeros(15,15);
%     im2(sub2ind([15,15],res(:,1),res(:,2))) = 1;
%     
%     figure(1); imshow(im1);
%     figure(2); imshow(im2);
end

