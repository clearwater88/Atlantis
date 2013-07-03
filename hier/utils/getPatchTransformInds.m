function [boundary,rotTemplate,templateMask] = getPatchTransformInds(template,poseCentre)
    % pose is [xCentre,yCentre,angle]

    rotTemplate = imrotate(template,-180*(poseCentre(3))/pi,'nearest','loose');
    templateMask = imrotate(ones(size(template)),-180*(poseCentre(3))/pi,'nearest','loose');
    
    boundary(:,1) = (poseCentre(1:2)-(size(rotTemplate)-1)/2)';
    boundary(:,2) = (poseCentre(1:2)+(size(rotTemplate)-1)/2)';
end
