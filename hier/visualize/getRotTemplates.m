function [templates,masks] = getRotTemplates(params,app)
    ags=params.angles;
    %ags = params.angleDisc(1):params.angleDisc(2):params.angleDisc(3);
    
    templates = cell(numel(app)-1,numel(ags));
    masks = cell(numel(app)-1,numel(ags));
    
    for(i=1:numel(app)-1) % last one is bg
        tp = app{i};
        for (j=1:numel(ags))
            templates{i,j} = trimIm(imrotate(tp,-180*(ags(j))/pi,'nearest'));
            masks{i,j} = trimIm(imrotate(ones(size(tp)),-180*(ags(j))/pi,'nearest'));
        end
    end
    
end
% rotTemplate = imrotate(template,-180*(ag)/pi,'nearest','loose');
