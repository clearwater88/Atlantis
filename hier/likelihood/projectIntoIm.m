function [likeIm,countsIm] = projectIntoIm(likeIm,countsIm,likeImAdd,countsAdd,bound)
    
    likeIm(bound(1,1):bound(1,2), bound(2,1):bound(2,2)) = ...
             likeIm(bound(1,1):bound(1,2), bound(2,1):bound(2,2)) + likeImAdd;
    
   countsIm(bound(1,1):bound(1,2), bound(2,1):bound(2,2)) = ...
             countsIm(bound(1,1):bound(1,2), bound(2,1):bound(2,2)) + countsAdd;
   
end

