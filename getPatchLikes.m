function res = getPatchLikes(patches,data,locs,counts)
    % res: [patchSize,#orientations,#locs] of patch likelihoods, for a
    %      patch being at this location and orientation
    
    %locs are possible brick centers

    pSize = ([size(patches,1),size(patches,2)]-1)/2;
    mask = counts>0;
    
    res = zeros([size(patches),size(locs,1)]);    
    for (i=1:size(locs,1))
        dataUse = data(locs(i,1)-pSize(1):locs(i,1)+pSize(1), ...
                       locs(i,2)-pSize(2):locs(i,2)+pSize(2));
        res(:,:,:,i) = bsxfun(@power,patches,dataUse) .* ...
                       bsxfun(@power,1-patches,1-dataUse);

        % set likelihood if undefined pixels to 0 (ok, since we're adding likelihoods)
        res(:,:,:,i) =  res(:,:,:,i).*mask;
    end
end