function res = evalLike(likes,counts,alpha)

    res = (likes./counts).^alpha;

end

% function [likeStructPx] = evalLike(data,templateStruct,initLikes,initCounts,params)
%     % evalautes likelihood at all positions in pose space (discretized)
%     % boundary says which pixels the patch overlaps, given appropriate pose
%     
%     % last element is always background model
%     
%     error('blah');
%     nTemplates = numel(templateStruct.app)-1;
%     
%     likeStructPx.likes = cell(nTemplates,1);
%     likeStructPx.poses = cell(nTemplates,1);
%     likeStructPx.counts = cell(nTemplates,1);
%     likeStructPx.masks = cell(nTemplates,1);
%     likeStructPx.bounds = cell(nTemplates,1);
%     
%     for (type=1:nTemplates)
% 
%         maxElem = size(data,1)*size(data,2)*numel(params.angles);
%         posesTemp = zeros(maxElem,3);
%         likesTemp = cell(maxElem,1);
%         countsTemp = cell(maxElem,1);
%         masksTemp = cell(maxElem,1);
%         boundariesTemp = zeros(3,2,maxElem);
%         
%         template = templateStruct.app{type};
%         
%         x=1:size(data,2);
%         y=1:size(data,1);
%         [x,y] = meshgrid(x(:),y(:));
%         pts = [y(:),x(:)];
%         pts = reshape(pts',[1,2,numel(pts)/2]);
%             
%         ct = 1;
%         for (j=1:numel(params.angles))
%             ag=params.angles(j);
%             rotTemplate = trimIm(imrotate(template,-180*(ag)/pi,'nearest','loose'));
%             templateMask = trimIm(imrotate(ones(size(template)),-180*(ag)/pi,'nearest','loose'));
%             
%             clear boundary;
%             boundary(:,1,:) = bsxfun(@minus,pts,(size(rotTemplate)-1)/2);
%             boundary(:,2,:) = bsxfun(@plus,pts,(size(rotTemplate)-1)/2);
%             boundary(3,:,:) = ag;
%             
%             outOfBounds = any(boundary(1:2,1,:) < 1) | ...
%                           any(bsxfun(@gt,boundary(1:2,2,:),size(data)'));
%             
%             b1 = boundary(:,:,~outOfBounds);      
%             b2 = reshape(b1(1:2,1:2,:),[4,numel(b1(1:2,1:2,:))/4]);            
%             rg = reshape([1:size(b2,2)],[1,1,size(b2,2)]);
%             
%             dataUse2 = arrayfun(@(x)(data(b2(1,x):b2(3,x),b2(2,x):b2(4,x))),rg,'UniformOutput',0);
%             dataUse2 = cell2mat(dataUse2);
%             
%             likeUse2 = arrayfun(@(x)(initLikes(b2(1,x):b2(3,x),b2(2,x):b2(4,x))),rg,'UniformOutput',0);
%             likeUse2 = cell2mat(likeUse2);
%             
%             countsUse2 = arrayfun(@(x)(initCounts(b2(1,x):b2(3,x),b2(2,x):b2(4,x))),rg,'UniformOutput',0);
%             countsUse2 = cell2mat(countsUse2);
%             
%             likePatch = templateStruct.mix(type)* ...
%                          bsxfun(@power,rotTemplate,dataUse2) .* ...
%                          bsxfun(@power,1-rotTemplate,1-dataUse2);
%             likePatch = bsxfun(@times,likePatch,templateMask);
%             likePatch = likePatch+likeUse2;
% 
%             counts = templateStruct.mix(type)*ones(size(likePatch));
%             counts = bsxfun(@times,counts,templateMask) + countsUse2;
%                         
%             nFill = sum(~outOfBounds);
%             
%             [y,x,z] = meshgrid(1:size(data,2),1:size(data,1),ag);
%             poses = [x(:),y(:),z(:)];
%             posesTemp(ct:ct-1+nFill,:) = poses(~outOfBounds,:);
%             
%             a=poses(~outOfBounds,1:2);
%             b=bsxfun(@minus,a,(size(rotTemplate)-1)/2);
%             c = any(b(:,1) < 1) | any(b(:,2) < 1);
%             assert(c == 0);
%             
%             
%             boundariesTemp(:,:,ct:ct-1+nFill) = b1;
%             
%             for (i=1:nFill)
%                 likesTemp{ct-1+i,1} = likePatch(:,:,i);
%                 masksTemp{ct-1+i,1} = templateMask;
%                 countsTemp{ct-1+i,1} = counts(:,:,i);
%             end
%             ct = ct+nFill;
%         end
%         
%         %clean up
%         posesTemp(ct:end,:) = [];
%         likesTemp(ct:end) = [];
%         countsTemp(ct:end) = [];
%         boundariesTemp(:,:,ct:end) = [];
%         masksTemp(:,:,ct:end) = [];
% 
%         likeStructPx.bounds{type} = boundariesTemp;
%         likeStructPx.poses{type} = posesTemp;
%         likeStructPx.likes{type} = likesTemp;
%         likeStructPx.counts{type} = countsTemp;
%         likeStructPx.masks{type} = masksTemp;
%     end
% end
% 
