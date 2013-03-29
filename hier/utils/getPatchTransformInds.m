function [patchRange,template] = getPatchTransformInds(brick, poseCellLocs, template)
    type = brick(2);
    brickInd = brick(3);
    poseCellCentre = poseCellLocs{type}(brickInd,:)';
    offset = brick(4:6);

    template = imrotate(template,-180*(poseCellCentre(3)+offset(3))/pi,'nearest','loose');

    topLeftLoc = poseCellCentre(1:2)+offset(1:2)-(size(template)'-1)/2;
    patchRange = [topLeftLoc, topLeftLoc+[size(template)'-1]];
end

