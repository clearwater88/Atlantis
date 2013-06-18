function [templateStruct] = learnTemplates(trainInds,params,templateStruct)

    trainData = cell(numel(trainInds),1);
    for (i=1:numel(trainInds))
        trainData{i} = readData(params,templateStruct.bg,trainInds(i));
    end

    nLocs = 500;

    templateMax = max(templateStruct.sizes,[],1);
    templateStore = zeros([templateMax,numel(trainData)*nLocs]);
    
    [xP,yP] = meshgrid(-(templateMax(2)-1)/2:(templateMax(2)-1)/2,-(templateMax(1)-1)/2:(templateMax(1)-1)/2);
    pts = [yP(:),xP(:)];
            
    count = 1;
    for (i=1:numel(trainData))
       dataUse = trainData{i};
       angle = getOrientation(double(dataUse),templateStruct.SIGMA);
       
       inkLocs = find(dataUse(:) > 0.5);
       locInd = randi(numel(inkLocs),nLocs,1);
       locs = inkLocs(locInd);
       
        for (j=1:numel(locs))
            [y,x]= ind2sub(size(dataUse),locs(j));
            angleUse = angle(y,x);
            if(isnan(angleUse)) continue; end;            
            
            R = [cos(angleUse),-sin(angleUse);sin(angleUse),cos(angleUse)];

            ptsRotate = pts*R';
            ptsCentred = bsxfun(@plus,ptsRotate,[y,x]);
            ptsCentred = round(ptsCentred);
             
            if(any((ptsCentred(:,1) <= 0) | ...
                   (ptsCentred(:,1) >= size(dataUse,1)) | ...
                   (ptsCentred(:,2) <= 0) | ...
                   (ptsCentred(:,2) >= size(dataUse,2)) ...
                  ))
               continue;
            end
           
            ptsInd = sub2ind(size(dataUse),ptsCentred(:,1),ptsCentred(:,2));

            templateStore(:,:,count) = reshape(dataUse(ptsInd),templateMax);
            
            ag(count) = angleUse;
            count = count+1;
            
%             figure(2);
%             imagescGray(templateStore(:,:,count-1));
%             
%             yStart = y-(templateMax(1)-1)/2;
%             yEnd = y+(templateMax(1)-1)/2;
%             xStart = x-(templateMax(2)-1)/2;
%             xEnd = x+(templateMax(1)-1)/2;
%             
%             if (yStart < 1 || yEnd > size(dataUse,1) || ...
%                 xStart < 1 || xEnd > size(dataUse,2)) continue; end;
%         
%             figure(1);
%             imagescGray(dataUse(yStart:yEnd,xStart:xEnd));
%             angleUse
%             pause;
        end
            
    end
    templateStore(:,:,count:end) = [];
    res = mean(templateStore,3);

    centre = (size(res)+1)/2;
    for (i=1:size(templateStruct.sizes,1))
        temp = res(centre(1)-(templateStruct.sizes(i,1)-1)/2:centre(1)+(templateStruct.sizes(i,1)-1)/2, ...
                   centre(2)-(templateStruct.sizes(i,2)-1)/2:centre(2)+(templateStruct.sizes(i,2)-1)/2);
        templateStruct.app{i} = temp;
    end
    templateStruct.app{end+1} = templateStruct.bg;

end

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

