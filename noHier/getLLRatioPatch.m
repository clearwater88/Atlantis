function [llRMap] = getLLRatioPatch(likeRatio,locs,imSize)
    % Compute patch-wise log-likelihood of patch, and arranges them
    % according to their centre
    % likeRatio: [patchSize,#orients,#locs,#oldSamples]
    % llRMap: [imSize,#orient,#oldSamples]

    logLikeRatioPatch = squeeze(sum(sum(log(likeRatio),1),2));
    logLikeRatioPatch = permute(logLikeRatioPatch,[2,1,3]);
    
    llRMap = log(zeros([imSize,size(logLikeRatioPatch,2),size(logLikeRatioPatch,3)]));
    for (i=1:size(locs,1))
        lc = locs(i,:);
        llRMap(lc(1),lc(2),:,:) = logLikeRatioPatch(i,:,:); 
    end
end

