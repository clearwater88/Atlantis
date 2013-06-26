function [likeStructPx] = evalLike(data,templateStruct,initLikes,initCounts,params)
    % evalautes likelihood at all positions in pose space (discretized)
    % boundary says which pixels the patch overlaps, given appropriate pose
    
    % last element is always background model
    nTemplates = numel(templateStruct.app)-1;
    
    likeStructPx.likes = cell(nTemplates,1);
    likeStructPx.poses = cell(nTemplates,1);
    likeStructPx.counts = cell(nTemplates,1);
    likeStructPx.masks = cell(nTemplates,1);
    likeStructPx.bounds = cell(nTemplates,1);
    
    for (type=1:nTemplates)

        maxElem = size(data,1)*size(data,2)*numel(params.angleDisc(1):params.angleDisc(2):params.angleDisc(3));
        posesTemp = zeros(maxElem,3);
        likesTemp = cell(maxElem,1);
        countsTemp = cell(maxElem,1);
        masksTemp = cell(maxElem,1);
        boundariesTemp = zeros(3,2,maxElem);
                
        template = templateStruct.app{type};
        ct = 1;
        for (ag=params.angleDisc(1):params.angleDisc(2):params.angleDisc(3))
            rotTemplate = imrotate(template,-180*(ag)/pi,'nearest','loose');
            templateMask = imrotate(ones(size(template)),-180*(ag)/pi,'nearest','loose');
            
            x=1:size(data,2);
            y=1:size(data,1);
            [x,y] = meshgrid(x(:),y(:));
            pts = [y(:),x(:)];
            pts = reshape(pts',[1,2,numel(pts)/2]);
            
            clear boundary;
            boundary(:,1,:) = bsxfun(@minus,pts,(size(rotTemplate)-1)/2);
            boundary(:,2,:) = bsxfun(@plus,pts,(size(rotTemplate)-1)/2);
            boundary(3,:,:) = ag;
            
            outOfBounds = any(boundary(1:2,1,:) < 1) | ...
                          any(bsxfun(@gt,boundary(1:2,2,:),size(data)'));
            for(y=1:size(data,2))
                for (x=1:size(data,1))
                    
                    ct2 = (y-1)*size(data,1)+x;
                    bdUse = boundary(:,:,ct2);
                    
                    % rotated patch falls outside? Then forget it
                    if(outOfBounds(ct2)) continue; end;
                    
                    dataUse = data(bdUse(1,1):bdUse(1,2), ...
                                   bdUse(2,1):bdUse(2,2));
                    likeUse = initLikes(bdUse(1,1):bdUse(1,2), ...
                                        bdUse(2,1):bdUse(2,2));
                    countsUse = initCounts(bdUse(1,1):bdUse(1,2), ...
                                           bdUse(2,1):bdUse(2,2));

                    likePatch = templateStruct.mix(type)*((rotTemplate.^dataUse).*((1-rotTemplate).^(1-dataUse)));
                    likePatch = likePatch.*templateMask;
                    likePatch = likePatch + likeUse;
                    
                    counts = templateStruct.mix(type)*ones(size(likePatch));
                    counts = counts.*templateMask + countsUse;

                    posesTemp(ct,:) = [x,y,ag];                    
                    likesTemp{ct,1} = likePatch;
                    masksTemp{ct,1} = templateMask;
                    countsTemp{ct,1} = counts;
                    boundariesTemp(:,:,ct) = bdUse;
                    ct = ct+1;
                end
            end
        end
        
        %clean up
        posesTemp(ct:end,:) = [];
        likesTemp(ct:end) = [];
        countsTemp(ct:end) = [];
        boundariesTemp(:,:,ct:end) = [];
        masksTemp(:,:,ct:end) = [];

        likeStructPx.bounds{type} = boundariesTemp;
        likeStructPx.poses{type} = posesTemp;
        likeStructPx.likes{type} = likesTemp;
        likeStructPx.counts{type} = countsTemp;
        likeStructPx.masks{type} = masksTemp;
    end
end

