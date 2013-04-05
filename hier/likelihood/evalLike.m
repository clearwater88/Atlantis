function [likes,boundaries,counts] = evalLike(data,templateStruct,params)

    % last element is always background model
    nTemplates = numel(templateStruct.app)-1;

    likes = cell(nTemplates,1);
    boundaries = cell(nTemplates,1);
    counts = cell(nTemplates,1);
    
    
    for (type=1:nTemplates)
        tic
        
        boundariesTemp = [];
        likesTemp = {};
        countsTemp = {};
        
        template = templateStruct.app{type};
        ct = 1;
        for (ag=params.angleDisc(1):params.angleDisc(2):params.angleDisc(3))
            rotTemplate = imrotate(template,-180*(ag)/pi,'nearest','loose');
            
            for (x=1:size(data,1))
                for(y=1:size(data,2))
                    poseCentre = [x,y,ag];
                    boundary(:,1) = (poseCentre(1:2)-(size(rotTemplate)-1)/2)';
                    boundary(:,2) = (poseCentre(1:2)+(size(rotTemplate)-1)/2)';
                    
                    % rotated patch falls outside? Then forget it
                    if(any(boundary(:,1) < 1)) continue; end;
                    if(any(boundary(:,2) > size(data)')) continue; end;
                    
                    boundariesTemp = cat(3,boundariesTemp,boundary);
                    
                    dataUse = data(boundary(1,1):boundary(1,2), ...
                                   boundary(2,1):boundary(2,2));
                    
                    likePatch = templateStruct.mix(type)*((rotTemplate.^dataUse).*((1-rotTemplate).^(1-dataUse)));
                    likesTemp{ct,1} = likePatch;
                    countsTemp{ct,1} = templateStruct.mix(type)*ones(size(likePatch));
                    ct = ct+1;
                end
            end
        end
        toc
        boundaries{type} = boundariesTemp;
        likes{type} = likesTemp;
        counts{type} = countsTemp;
    end


end

