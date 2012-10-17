function [res,corresPts,corresPtsInd] = rotatePts(inPts,centre,rot,fs,fillSource)
    % inPts: nPts x 2
    % centre: [1,2]
    % looks like counter clockwise rotation because y-axis points down
    % image

    % For coordinates in y-x format
    % this is really a backwarp
    rotBackMat = [cos(-rot), sin(-rot); -sin(-rot), cos(-rot)];
    rotForMat = [cos(rot),sin(rot); -sin(rot) cos(rot)];
    
    temp=bsxfun(@minus,inPts,centre);
    temp(:,1) = temp(:,1)*(1-fs);
    rotInPts = round(bsxfun(@plus,(rotForMat*temp')',centre));
    if (fillSource == 1)        
        res = rotInPts;
        corresPts = -1;
        corresPtsInd = -1;
        return;
    end
    
    minYX = min(rotInPts,[],1);
    maxYX = max(rotInPts,[],1);    
    
    [newY,newX] = meshgrid(minYX(1):maxYX(1),minYX(2):maxYX(2));
    
    res = [newY(:),newX(:)];
    
    temp = (rotBackMat*bsxfun(@minus,res,centre)')';
    temp(:,1) = temp(:,1)/(1-fs);
    
    corresPts = round(bsxfun(@plus,temp,centre));

    % assumes points are discrete, not continuous-valued
    badPts = ~(ismember(corresPts(:,1),inPts(:,1)) & ...
               ismember(corresPts(:,2),inPts(:,2)));

    res(badPts,:) = [];
    corresPts(badPts,:) = [];
    
    [~,corresPtsInd] = ismember(corresPts,inPts,'rows');

end

