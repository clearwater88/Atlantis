function mainGen(imSize, noiseParam, useContext,alpha,resFolder,nStart,nTrials)
% mainGen([50,50], 0.1, 1,1,'resTemp/',0,1);
    startup;
    
    genFolder = 'genDataEx/';
    genStr= [genFolder,'ex%d_imSize', int2str(imSize(1)), '-', int2str(imSize(2)), ...
               '_', 'noiseParam-', int2str(100*noiseParam)] ;
           
    if(isempty(resFolder))
        resFolder = 'resDataEx/';
    end
    if(isempty(alpha))
        alpha = 100;
    end
    alpha = alpha/100; % stupid cluster thing
    [~,~]=mkdir(resFolder);

    %[trainInds,testInds] = splitData(10,0.5,0.5);
    trainInds = [1:5];
    testInds=[6:10];
    
%     params = initParams;
%     params.downSampleFactor = ds;
%     params.useContext = useContext;
%     params.alpha = alpha;
    
    for (t=nStart:nStart+nTrials-1)
       
        % inference
        for (i=1:numel(testInds))
            
            load(sprintf(genStr,testInds(i)),'probPixel', 'mask', 'data', 'cleanData','ruleStruct','probMapStruct','templateStruct','ruleStruct','params');
            params.useContext=useContext;

            cleanTestData = cleanData;
            testData = data;
            
            imSize = size(testData);
            cellParams = initPoseCellCentres(imSize,templateStruct.sizes);
    
            selfRootStr = 'selfRoot';
            for (j=1:numel(params.probRoot))
                selfRootStr = [selfRootStr, '-', int2str(1000000*params.probRoot(j))];
            end
            
            saveStr = [resFolder,'testSweep0', int2str(testInds(i)), '_', ...
                       'imSize', int2str(imSize(1)),'-',int2str(imSize(2)), '_', ...
                       ruleStruct.toString(ruleStruct), '_', ...
                       probMapStruct.toString(probMapStruct), '_', ...
                       params.toString(params), '_', ...
                       cellParams.toString(cellParams), '_', ...
                       'context', int2str(params.useContext), '_', ...
                       'alpha', int2str(100*alpha), '_', ...
                       templateStruct.toString(templateStruct), '-', ...
                       selfRootStr, ...
                       '_noise', int2str(100*templateStruct.bg), ...
                       '_trial', int2str(t)];
                   
            if(exist([saveStr,'.mat'],'file'))
                display(['File exists: ', saveStr]);
            else
                [allParticles,probOn,probOnFinal,msgs] = doInfer(testData,params,ruleStruct,templateStruct,probMapStruct,cellParams,imSize);
                finalParticles = allParticles{end};
                save(saveStr,'cleanTestData', 'testData', 'allParticles', 'probOn', ...
                    'templateStruct', 'probMapStruct', 'ruleStruct', 'cellParams', ...
                    'params','msgs', 'finalParticles','ruleStruct','probOnFinal','-v7.3');
            end

        end
    end
end