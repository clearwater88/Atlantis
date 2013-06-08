function angle = getOrientation(im,sigma,angles)

    im = double(im);

    cellSize = 2*ceil((3*sigma)/2)+1;
    [resX,resY] = dGauss(sigma,cellSize);

    filtX = cos(0)*resX + sin(0)*resY;
    filtY = cos(pi/2)*resX + sin(pi/2)*resY; 
    angle = atan(conv2(im,filtY)./conv2(im,filtX));

%     for (i=1:numel(angles))
%         filt = cos(angles(i))*resX + sin(angles(i))*resY;
% 
%         resp(:,:,i) = conv2(im,filt);
% % 
% %         figure(1);
% %         imagescGray(filt);
% %         figure(2);
% %         imagescGray(abs(resp(:,:,i)));
% %         pause;
% 
%     end
%     [~,ind] = max(resp,[],3);
%     angle = angles(ind);
end

function [resX,resY] = dGauss(sigma,cellSize)
    x = -(cellSize-1)/2:(cellSize-1)/2;
    y = -(cellSize-1)/2:(cellSize-1)/2;
    
    [xPts,yPts] = meshgrid(x(:),y(:));
    pts = [yPts(:),xPts(:)];
    resX = reshape(mvnpdf(pts,[0,0],[sigma,sigma]),[cellSize,cellSize]);
    
    resX = bsxfun(@times,resX,-x/sigma^2);
    resY = resX';
end

