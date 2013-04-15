function [likeStructPx] = evalLike(data,templateStruct,params)
    % evalautes likelihood at all positions in pose space (discretized)

    % last element is always background model
    nTemplates = numel(templateStruct.app)-1;

    eps=0.00000000001; % for numerical issues
    
    likeStructPx.likes = cell(nTemplates,1);
    likeStructPx.boundaries = cell(nTemplates,1);
    likeStructPx.poses = cell(nTemplates,1);
    likeStructPx.counts = cell(nTemplates,1);
    
    for (type=1:nTemplates)


        
        maxElem = size(data,1)*size(data,2)*numel(params.angleDisc(1):params.angleDisc(2):params.angleDisc(3));
        posesTemp = zeros(maxElem,3);
        likesTemp = cell(maxElem,1);
        countsTemp = cell(maxElem,1);
        boundariesTemp = zeros(3,2,maxElem);
                
        template = templateStruct.app{type};
        ct = 1;
        for (ag=params.angleDisc(1):params.angleDisc(2):params.angleDisc(3))
            rotTemplate = imrotate(template,-180*(ag)/pi,'nearest','loose');
            
            for (x=1:size(data,1))
                for(y=1:size(data,2))
                    pt = [x,y,ag];
                    boundary(:,1) = [(pt(1:2)-(size(rotTemplate)-1)/2)';ag];
                    boundary(:,2) = [(pt(1:2)+(size(rotTemplate)-1)/2)';ag];
                    % rotated patch falls outside? Then forget it
                    if(any(boundary(1:2,1) < 1)) continue; end;
                    if(any(boundary(1:2,2) > size(data)')) continue; end;

                    dataUse = data(boundary(1,1):boundary(1,2), ...
                                   boundary(2,1):boundary(2,2));
                    
                    likePatch = templateStruct.mix(type)*((rotTemplate.^dataUse).*((1-rotTemplate).^(1-dataUse)));
                    
                    % hack for numerical stability
                    counts2 = templateStruct.mix(type)*ones(size(likePatch));
                    counts2(likePatch==0) = eps;
                    likePatch(likePatch==0) = eps;
                    
                    posesTemp(ct,:) = [x,y,ag];
                    likesTemp{ct,1} = likePatch;
                    countsTemp{ct,1} = counts2;
                    boundariesTemp(:,:,ct) = boundary;
                    ct = ct+1;
                end
            end
        end
        
        %clean up
        posesTemp(ct:end,:) = [];
        likesTemp(ct:end) = [];
        countsTemp(ct:end) = [];
        boundariesTemp(:,:,ct:end) = [];

        likeStructPx.boundaries{type} = boundariesTemp;
        likeStructPx.poses{type} = posesTemp;
        likeStructPx.likes{type} = likesTemp;
        likeStructPx.counts{type} = countsTemp;
    end
end

