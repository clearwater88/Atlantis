function likeRatio = getLikeRatio(patchLikes,patchCounts,counts,like,locs)
 
    pSize = ([size(patchLikes,1),size(patchLikes,2)]-1)/2;
    
    counts = reshape(counts,[size(counts,1),size(counts,2),1,1,size(counts,3)]);
    like = reshape(like,[size(like,1),size(like,2),1,1,size(like,3)]);
        
    likeOld = zeros([pSize*2+1,1,size(locs,1),size(like,5)]);
    countOld = zeros([pSize*2+1,1,size(locs,1),size(like,5)]);

    for (i=1:size(locs,1))
        likeOld(:,:,:,i,:) = like(locs(i,1)-pSize(1):locs(i,1)+pSize(1), ...
                              locs(i,2)-pSize(2):locs(i,2)+pSize(2),1,1,:);
        countOld(:,:,:,i,:) = counts(locs(i,1)-pSize(1):locs(i,1)+pSize(1), ...
                               locs(i,2)-pSize(2):locs(i,2)+pSize(2),1,1,:);
    end
    
    newLike = bsxfun(@plus,patchLikes,likeOld)./bsxfun(@plus,patchCounts,countOld);
    likeRatio = bsxfun(@rdivide,newLike,(likeOld./countOld));

end

 