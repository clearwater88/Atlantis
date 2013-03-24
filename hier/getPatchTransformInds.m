function [patchRange,template] = getPatchTransformInds(brick, template)
    poseCellCentre = brick(4:6);
    offset = brick(7:9);

    template = imrotate(template,-180*(poseCellCentre(3)+offset(3))/pi,'nearest','loose');

    topLeftLoc = poseCellCentre(1:2)+offset(1:2)-(size(template)'-1)/2;
    patchRange = [topLeftLoc, topLeftLoc+[size(template)'-1]];
end

