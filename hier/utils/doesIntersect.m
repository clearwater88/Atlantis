function res = doesIntersect(dirtyRegion,boundaries)
    res = intersectD(dirtyRegion(1,:),boundaries(1,:,:)) & ...
          intersectD(dirtyRegion(2,:),boundaries(2,:,:));
end

function res = intersectD(dirtyRegion,boundaries)
    res = bsxfun(@ge,boundaries(1,1,:),dirtyRegion(1,1)) & ...
          bsxfun(@le,boundaries(1,1,:),dirtyRegion(1,2));
      
    res2 = bsxfun(@ge,dirtyRegion(1,1),boundaries(1,1,:)) & ...
           bsxfun(@le,dirtyRegion(1,1),boundaries(1,2,:));
      
    res = squeeze(res | res2);
end