function [res] = makeCollage(ims,sz)
    BORDER = 5;
    imSize = size(ims{1});
    
    
    res = ones(imSize(1)*sz(1) + (sz(1)-1)*BORDER,imSize(2)*sz(2) + (sz(2)-1)*BORDER,imSize(3));
    res = bsxfun(@times,res,reshape([0.2,0.4,0.4],[1,1,3]));
    
    id = 1;
    for (y=1:sz(1))
       for(x=1:sz(2))
          if(id > numel(ims)) break; end;
          
          yStart = (y-1)*(imSize(1)+BORDER)+1;
          yEnd = yStart + imSize(1)-1;
          
          xStart = (x-1)*(imSize(2)+BORDER)+1;
          xEnd = xStart + imSize(2)-1;
          
          res(yStart:yEnd,xStart:xEnd,:) = ims{id};
          id=id+1;
          
       end
    end

end

