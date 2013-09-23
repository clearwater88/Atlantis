function [app] = setTemplateApp(sizes)

%     sizesUse =  [23,9; ...
%                  11,7; ...
%                  5,3];
             
    sizesUse = [11,3; ...
                 7,3; ...
                 5,3];

    probRange=[0.5,0.9];
             
    temp = abs(sizes(:)-sizesUse(:));
    assert(max(temp) < 0.0001);

    stds(:,:,1) = diag([3,7]);
    stds(:,:,2) = diag([0.5,3]);
    stds(:,:,3) = diag([0.2,1]);
    
    for (i=1:size(sizesUse,1))
        st = floor(sizesUse(i,1)/2);
        x = [-st:-st+sizesUse(i,1)-1];
        
        st = floor(sizesUse(i,2)/2);
        y = [-st:-st+sizesUse(i,2)-1];
        
        [y,x] = meshgrid(y,x);
        pts = [x(:),y(:)];
        
        f = mvnpdf(pts,[0,0],stds(:,:,i));
        rangeF = [min(f(:)),max(f(:))];
        m = (probRange(1)-probRange(2))/(rangeF(1)-rangeF(2));
        
        app{i} = m*reshape(f,sizesUse(i,:))+probRange(1);
    end

end

