function [templateStruct] = learnTemplates(trainInds,params,templateStruct)

    trainData = cell(numel(trainInds),1);
    for (i=1:numel(trainInds))
        trainData{i} = readData(params,templateStruct.bg,trainInds(i));
    end

    nLocs = 500;

    templateMax = max(templateStruct.sizes,[],1);
    
    templateStore = zeros([templateMax,numel(trainData)*nLocs]);
    
    count = 1;
    for (i=1:numel(trainData))
       dataUse = trainData{i};
       angle = getOrientation(double(dataUse),templateStruct.SIGMA,templateStruct.angles);
       
       inkLocs = find(dataUse(:) > 0.5);
       locInd = randi(numel(inkLocs),nLocs,1);
       locs = inkLocs(locInd);
       
        for (j=1:numel(locs))
            [y,x]= ind2sub(size(dataUse),locs(j));
            angleUse = angle(y,x);
            if(isnan(angleUse)) continue; end;
            %angleUse = pi/2;
            
            [xP,yP] = meshgrid(-(templateMax(2)-1)/2:(templateMax(2)-1)/2,-(templateMax(1)-1)/2:(templateMax(1)-1)/2);
            ptsCentred = [yP(:),xP(:)];
            
            R = [cos(angleUse),sin(angleUse);-sin(angleUse),cos(angleUse)];

            ptsRotate = ptsCentred*R';
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
            
            ptsInd = max(ptsInd,1); ptsInd = min(ptsInd,numel(dataUse));
            
            temp = reshape(dataUse(ptsInd),templateMax);
            
            templateStore(:,:,count) = temp;
            ag(count) = angleUse;
            count = count+1;
            
            
%             [dXtemp,dYtemp] = gradient(double(temp));
            
%             [dXtemp((end+1)/2,(end+1)/2),dYtemp((end+1)/2,(end+1)/2)]
            
%             figure(1);
%             % bigger
%             a=(dataUse(y-(templateMax(1)+1)/2:y+(templateMax(1)+1)/2, ...
%                                x-(templateMax(1)+1)/2:x+(templateMax(1)+1)/2));
%             imshowFull(a);
%             figure(2);
%             imshowFull(temp);
%             title(int2str(j));
            
        end
            
    end
    templateStore(:,:,count:end) = [];
    res = mean(templateStore,3);
    
%     for (i=1:size(templateStore,3))
%         imagescGray(templateStore(:,:,i));
%         ag(i)
%         pause;
%     end

    centre = (size(res)+1)/2;
    for (i=1:size(templateStruct.sizes,1))
        temp = res(centre(1)-(templateStruct.sizes(i,1)-1)/2:centre(1)+(templateStruct.sizes(i,1)-1)/2, ...
                   centre(2)-(templateStruct.sizes(i,2)-1)/2:centre(2)+(templateStruct.sizes(i,2)-1)/2);
        templateStruct.app{i} = temp;
    end
    templateStruct.app{end+1} = templateStruct.bg;



end

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


