function [like] = computeFullLike(fg,bg,counts)
    like = fg;
    mask = counts>0;
    like(mask) = like(mask)./counts(mask);
    like = like.*mask + bg.*(1-mask);  
end

