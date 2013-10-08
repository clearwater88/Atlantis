function getDirtyData(nStart,nEnd,imSize,noiseParam,templateStrat)
    genFolder = 'genDataEx/';
    loadStr= [genFolder,'exClean%d_imSize', int2str(imSize(1)), '-', int2str(imSize(2))] ;
    saveStr = [genFolder,'ex%d_imSize', int2str(imSize(1)), '-', int2str(imSize(2)),'_noiseParam-', int2str(100*noiseParam), 'templateStrat-', int2str(templateStrat)];
    
    for(n=nStart:nEnd)
        load(sprintf(loadStr,n), 'particle', 'templateStruct', 'params', 'ruleStruct','probMapStruct');
        templateStruct.bg = noiseParam;
        
        if (templateStrat==0)
            % set templates
            templateStruct.app = setTemplateApp(templateStruct.sizes);
            templateStruct.app{end+1} = noiseParam;
            cleanTemplates = templateStruct.app;
        elseif(templateStrat==1)
            %load([genFolder, 'templateBSDS', int2str(noiseParam*100)],'templateStruct');
            load([genFolder, 'templateBSDS0'],'templateStruct');
            templateStruct.app{end} = noiseParam;
            cleanTemplates = templateStruct.app;
        else
            error('bad template strat');
        end
        
        for (i=1:numel(templateStruct.app))
            temp = templateStruct.app{i}*(1-noiseParam) + ...
                (1-templateStruct.app{i})*noiseParam;
            templateStruct.app{i} = temp;
        end

        [rotTemplatesClean,~] = getRotTemplates(params,cleanTemplates);
        
        probPixel = viewAllParticles(toCell(particle),rotTemplatesClean,params,imSize);
        cleanData = rand(imSize) < probPixel;
        
        flip = rand(imSize) < noiseParam; %flip=1 means flip pixel
        
        data = cleanData.*(1-flip) + (1-cleanData).*flip;
        
%         figure(1);
%         subplot(1,3,1); imshow(cleanData);
%         subplot(1,3,2); imshow(data);
%         subplot(1,3,3); imshow(probPixel);

        save(sprintf(saveStr,n), 'particle', 'probPixel','data','cleanData', 'templateStruct', 'params', 'ruleStruct','probMapStruct', '-v7.3');
    end
    
end

