function [posesStruct] = getPoses(params,templateStruct)

    nTemplates = numel(templateStruct.app)-1;
    posesStruct.angles = params.angles;

    posesStruct.rotTemplate = cell(nTemplates,1);
    posesStruct.mask = cell(nTemplates,1);
    posesStruct.counts = cell(nTemplates,1);
    
    for (type=1:nTemplates)
        template = templateStruct.app{type};
        
        rotTemplate = cell(numel(posesStruct.angles),1);
        mask = cell(numel(posesStruct.angles),1);
        counts = cell(numel(posesStruct.angles),1);
        for (j=1:numel(params.angles))
            ag = posesStruct.angles(j);
            rotTemplate{j} = trimIm(imrotate(template,-180*(ag)/pi,'nearest','loose'));
            mask{j} = trimIm(imrotate(ones(size(template)),-180*(ag)/pi,'nearest','loose'));
            counts{j} = mask{j}.*(templateStruct.mix(type)*ones(size(mask{j})));
        end
        posesStruct.rotTemplate{type} = rotTemplate;
        posesStruct.mask{type} = mask;
        posesStruct.counts{type} = counts;
    end
    
    % poses can at most be centred at all pixels, all orientations
    maxElem = prod(params.imSize)*numel(params.angles);
    
    posesStruct.poses = cell(nTemplates,1);
    posesStruct.bounds = cell(nTemplates,1);
    for (type=1:nTemplates)

        posesTemp = zeros(maxElem,3);
        boundariesTemp = zeros(3,2,maxElem);
        
        [x,y] = meshgrid(1:params.imSize(2),1:params.imSize(1));
        pts = [y(:),x(:)];
        pts2 = reshape(pts',[1,2,numel(pts)/2]);
            
        ct = 1;
        for (j=1:numel(params.angles))
            ag=params.angles(j);
            rotTemplate = posesStruct.rotTemplate{type}{j};
            
            clear boundary;
            boundary(:,1,:) = bsxfun(@minus,pts2,(size(rotTemplate)-1)/2);
            boundary(:,2,:) = bsxfun(@plus,pts2,(size(rotTemplate)-1)/2);
            boundary(3,:,:) = ag;
            
            outOfBounds = any(boundary(1:2,1,:) < 1) | ...
                          any(bsxfun(@gt,boundary(1:2,2,:),params.imSize'));
            
            b1 = boundary(:,:,~outOfBounds);      
            nFill = sum(~outOfBounds);
            
            poses = [pts,ag*ones(size(pts,1),1)];
            posesTemp(ct:ct-1+nFill,:) = poses(~outOfBounds,:);            
            
            boundariesTemp(:,:,ct:ct-1+nFill) = b1;
            
            ct = ct+nFill;
        end
        
        %clean up
        posesTemp(ct:end,:) = [];
        boundariesTemp(:,:,ct:end) = [];

        posesStruct.bounds{type} = boundariesTemp;
        posesStruct.poses{type} = posesTemp;
    end

end

