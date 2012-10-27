function likeRatio = getLikeRatio(patchLikes,patchCounts,counts,like,locs)
 
    pSize = ([size(patchLikes,1),size(patchLikes,2)]-1)/2;

    likeRatio = zeros([size(patchLikes),size(counts,3)]);
    
    counts = reshape(counts,[size(counts,1),size(counts,2),1,1,size(counts,3)]);
    like = reshape(like,[size(like,1),size(like,2),1,1,size(like,3)]);
    
    for (i=1:size(locs,1))
        likeUse = patchLikes(:,:,:,i);
        
        likeOld = like(locs(i,1)-pSize(1):locs(i,1)+pSize(1), ...
                       locs(i,2)-pSize(2):locs(i,2)+pSize(2),1,1,:);
        countOld = counts(locs(i,1)-pSize(1):locs(i,1)+pSize(1), ...
                          locs(i,2)-pSize(2):locs(i,2)+pSize(2),1,1,:);
        
                      
        newLike = bsxfun(@plus,likeUse,likeOld)./bsxfun(@plus,patchCounts,countOld);
        likeRatio(:,:,:,i,:) = bsxfun(@rdivide,newLike,(likeOld./countOld));
    end
end

 