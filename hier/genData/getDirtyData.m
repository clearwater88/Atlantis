function getDirtyData(nStart,nEnd,imSize,noiseParam)
    genFolder = 'genDataEx/';
    loadStr= [genFolder,'exClean%d_imSize', int2str(imSize(1)), '-', int2str(imSize(2))] ;
    saveStr = [genFolder,'ex%d_imSize', int2str(imSize(1)), '-', int2str(imSize(2)),'_noiseParam-', int2str(100*noiseParam)];
    
    for(n=nStart:nEnd)
        load(sprintf(loadStr,n), 'particle', 'probPixel', 'mask','cleanData', 'templateStruct', 'params', 'ruleStruct','probMapStruct');
        
        templateStruct.bg = noiseParam;
        templateStruct.app{end} = noiseParam;
        
        bg = rand(imSize) < templateStruct.bg;
        data = cleanData.*mask + bg.*(1-mask);
        
        save(sprintf(saveStr,n), 'particle', 'probPixel', 'mask','data','cleanData', 'templateStruct', 'params', 'ruleStruct','probMapStruct', '-v7.3');
    end
    
end

