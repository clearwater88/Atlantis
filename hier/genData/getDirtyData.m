function getDirtyData(nExamples,imSize,noiseParam)
    genFolder = 'genDataEx/';
    loadStr= [genFolder,'exClean%d_imSize', int2str(imSize(1)), '-', int2str(imSize(2))] ;
    saveStr = [genFolder,'ex%d_imSize', int2str(imSize(1)), '-', int2str(imSize(2)),'_noiseParam-', int2str(100*noiseParam)];
    
    for(n=1:nExamples)
        load(sprintf(loadStr,n), 'probPixel', 'mask','cleanData', 'templateStruct', 'params', 'ruleStruct','probMapStruct');
        
        templateStruct.bg = noiseParam;
        templateStruct.app{4} = noiseParam;
        
        bg = rand(imSize) < templateStruct.bg;
        data = cleanData.*mask + bg.*(1-mask);
        
        save(sprintf(saveStr,n), 'probPixel', 'mask','data','cleanData', 'templateStruct', 'params', 'ruleStruct','probMapStruct', '-v7.3');
    end
    
end

