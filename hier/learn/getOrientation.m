function res = getOrientation(im,sigma)
    im = double(im);
    
    cellSize = 10*ceil((3*sigma)/2)+1;
    [filt] = d2Gauss(sigma,cellSize);
    
    for (i=1:3)
        resConv(:,:,i) = conv2(im,filt(:,:,i),'same');
    end
    
    temp = (sqrt(3)*(resConv(:,:,2) - resConv(:,:,3)))./ ...
           (2*resConv(:,:,1) - resConv(:,:,2) - resConv(:,:,3));
                      
    angleSol = atan(temp)/2;
    angleSol(isnan(angleSol)) = 0; % redfine 0/0 as 0.
    
    ag = [0,pi/2];
    for (i=1:numel(ag))
        steer(:,:,i) = evalSteerable(angleSol+ag(i), resConv);
    end
    [~,win] = min(steer,[],3);
    res = angleSol+ag(win);
end

function res = evalSteerable(angle, resConv) 
    res = (1/3)*bsxfun(@times,1+cos(2*angle),resConv(:,:,1)) + ...
          (1/3)*bsxfun(@times,1+cos(2*(angle-pi/3)),resConv(:,:,2)) + ...
          (1/3)*bsxfun(@times,1+cos(2*(angle-2*pi/3)),resConv(:,:,3));
end

function [res] = d2Gauss(sigma,cellSize)
    
    x = -(cellSize-1)/2:(cellSize-1)/2;
    y = -(cellSize-1)/2:(cellSize-1)/2;
    
    [xPts,yPts] = meshgrid(x(:),y(:));
    pts = [yPts(:),xPts(:)];

    res(:,:,1) = reshape(mvnpdf(pts,[0,0],[sigma,sigma]),[cellSize,cellSize]);
    res(:,:,1) = bsxfun(@times,res(:,:,1),x.^2/sigma^4-1/sigma^2);
    
    res(:,:,2) = imrotate(res(:,:,1),60,'bilinear','crop');
    res(:,:,3) = imrotate(res(:,:,1),120,'bilinear','crop');
end