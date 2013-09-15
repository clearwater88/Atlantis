function [templateStruct] = learnTemplates(trainInds,params,templateStruct)

    trainData = cell(numel(trainInds),1);
    noisyTrainData = cell(numel(trainInds),1);
    for (i=1:numel(trainInds))
        [trainData{i},noisyTrainData{i}] = readData(params,templateStruct.bg,trainInds(i));
    end

    nLocs = 500;

    templateMax = max(templateStruct.sizes,[],1);
    templateStore = zeros([templateMax,numel(trainData)*nLocs]);
    
    [xP,yP] = meshgrid(-(templateMax(2)-1)/2:(templateMax(2)-1)/2,-(templateMax(1)-1)/2:(templateMax(1)-1)/2);
    pts = [yP(:),xP(:)];
            
    count = 1;
    for (i=1:numel(trainData))
        % use clean data to detect orientation, and to select inked points
       dataUseLocs = trainData{i};
       angle = getOrientation(double(dataUseLocs),templateStruct.SIGMA);
       inkLocs = find(dataUseLocs(:) > 0.5);
       
       % use noisy data to actually learn templates
       dataUse = noisyTrainData{i};
       
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

