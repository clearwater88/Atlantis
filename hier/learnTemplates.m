function [templateStruct] = learnTemplates(trainData,templateStruct)

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

