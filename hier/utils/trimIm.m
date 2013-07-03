function [im] = trimIm(im)

    while(1)
        if(any(im(:,1)~=0)) break; end;
        im(:,1)=[];
    end
    while(1)
        if(any(im(:,end)~=0)) break; end;
        im(:,end)=[];
    end
    
    while(1)
        if(any(im(1,:)~=0)) break; end;
        im(1,:)=[];
    end
    while(1)
        if(any(im(end,:)~=0)) break; end;
        im(end,:)=[];
    end
end

