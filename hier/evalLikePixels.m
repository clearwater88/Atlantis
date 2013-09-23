function res = evalLikePixels(template,dataUse,mask,mix)
    
    if(isempty(mask)) mask = 1; end
    res = bsxfun(@power,template,dataUse) .* ...
          bsxfun(@power,1-template,1-dataUse);
      
    res = mix*bsxfun(@times,res,mask);
end