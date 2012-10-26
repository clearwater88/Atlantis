function likeRatio = getLikeRatio(patchLikes,patchCounts,counts,like,locs)
 
    pSize = ([size(patchLikes,1),size(patchLikes,2)]-1)/2;

    likeRatio = zeros(size(patchLikes));
    
    for (i=1:size(locs,1))
        likeUse = patchLikes(:,:,:,i);
        
        likeOld = like(locs(i,1)-pSize(1):locs(i,1)+pSize(1), ...
                       locs(i,2)-pSize(2):locs(i,2)+pSize(2));
        countOld = counts(locs(i,1)-pSize(1):locs(i,1)+pSize(1), ...
                          locs(i,2)-pSize(2):locs(i,2)+pSize(2));
        
                      
        newLike = bsxfun(@plus,likeUse,likeOld)./bsxfun(@plus,patchCounts,countOld);
        likeRatio(:,:,:,i) = bsxfun(@rdivide,newLike,(likeOld./countOld));
    end
end

 