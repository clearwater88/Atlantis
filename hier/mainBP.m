function mainBP(ds,noiseParam,useContext,alpha,resFolder,nStart,nTrials)
% mainBP(16,0.1,1,1,'resTemp/',0,1);
    if(isempty('resFolder'))
        resFolder = 'resTemp/';
    end
    if(isempty('alpha'))
        alpha = 1;
    end
    [~,~]=mkdir(resFolder);

    startup;

    %[trainInds,testInds] = splitData(10,0.5,0.5);
    trainInds = [1:3];
    testInds=[6:10];
    
    params = initParams;
    params.downSampleFactor = ds;
    params.useContext = useContext;
    params.alpha = alpha;
    
    for (t=nStart:nStart+nTrials-1)
        templateStruct = initTemplates();
        
        assert(numel(params.probRoot) == numel(templateStruct.mix)-1);
        
        templateStruct.bg=noiseParam;
        ruleStruct = initRules(useContext);
        probMapStruct = initProbMaps(ruleStruct,templateStruct.sizes);

        [templateStruct,probMapStruct,ruleStruct] = doLearning(trainInds,params,ruleStruct,templateStruct,probMapStruct);
        save('learning2', 'templateStruct','probMapStruct','ruleStruct', '-v7.3');
        % inference
        for (i=1:numel(testInds))
            [cleanTestData,testData] = readData(params,templateStruct.app{end},testInds(i));
            imSize = size(testData);
            cellParams = initPoseCellCentres(imSize);
    
            saveStr = [resFolder,'testSweep0', int2str(testInds(i)), '_', ruleStruct.toString(ruleStruct), '_', ...
                       probMapStruct.toString(probMapStruct), '_', ...
                       params.toString(params), '_', ...
                       cellParams.toString(cellParams), '_', ...
                       'context', int2str(params.useContext), '_', ...
                       'alpha', int2str(1000*alpha), '_', ...
                       templateStruct.toString(templateStruct), '-', ...
                       'selfRoot', int2str(1000000*params.probRoot), '-noise', int2str(100*templateStruct.bg), '_trial', int2str(t)];
                   
            if(exist([saveStr,'.mat'],'file'))
                display(['File exists: ', saveStr]);
            else
                [allParticles,probOn,probOnFinal,msgs] = doInfer(testData,params,ruleStruct,templateStruct,probMapStruct,cellParams,imSize);
                finalParticles = allParticles{end};
                save(saveStr,'cleanTestData', 'testData', 'allParticles', 'probOn', ...
                    'templateStruct', 'probMapStruct', 'ruleStruct', 'cellParams', ...
                    'params','msgs', 'finalParticles','finalProbOn','ruleStruct','probOnFinal','-v7.3');
            end

        end
    end
end