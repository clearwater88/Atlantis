function im = viewCellCentre(pose,template,im,figNum)
	[patchRange,template] = getPatchTransformInds(template, pose);
    im(patchRange(1,1):patchRange(1,2), patchRange(2,1):patchRange(2,2)) = ...
        im(patchRange(1,1):patchRange(1,2), patchRange(2,1):patchRange(2,2)) + template;
    
    if(nargin < 4)
        figure;
    else
        figure(figNum);
    end
    imagescGray(im);
end