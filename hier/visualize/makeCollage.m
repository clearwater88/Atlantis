function [res] = makeCollage(ims,sz)
    %ims: images to be collaged. Must be all same size.
    %sz: shape of collage to make. (eg, [3,3] means lay out ims in 3x3
    %    grid)

    BORDER = 5;
    imSize = size(ims{1});
    if(numel(imSize) < 3)
        imSize(3) = 1;
    end
    
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
          
          temp = ims{id};
          if(imSize(3) ~= 3)
             temp= repmat(temp,[1,1,3]);
          end
          res(yStart:yEnd,xStart:xEnd,:) = temp;
          
          id=id+1;
          
       end
    end

end

