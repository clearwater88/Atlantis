function mainBP(ds,noiseParam,useContext,alpha,resFolder,nStart,nTrials)
% mainBP(8,0.1,1,'resTemp',0,1)
    if(isempty('resFolder'))
        resFolder = 'resTemp/';
    end
    if(isempty('alpha'))
        alpha = 1;
    end
    [~,~]=mkdir(resFolder);

    startup;

    %[trainInds,testInds] = splitData(10,0.5,0.5);
    trainInds = [1:5];
    testInds=[6:10];
    %splitData(nData,nTrainPerc,nTestPerc,trainMask)
    
    params = initParams;
    params.downSampleFactor = ds;
    params.useContext = useContext;
    params.alpha = alpha;
    
    for (t=nStart:nStart+nTrials-1)
        templateStruct = initTemplates();
        templateStruct.bg=noiseParam;
        ruleStruct = initRules(useContext);
        probMapStruct = initProbMaps(ruleStruct,templateStruct.sizes);
    
        % learning
        if(templateStruct.doLearning == 1)
            templateStruct = learnTemplates(trainInds,params,templateStruct);
        end
        
        % inference
        for (i=1:numel(testInds))
            [cleanTestData,testData] = readData(params,templateStruct.app{end},testInds(i));

            imSize = size(testData);
            cellParams = initPoseCellCentres(imSize);

            
            % careful with new probMap distributions
            mapStr= ['sweep0', ruleStruct.toString(ruleStruct), '_', probMapStruct.toString(probMapStruct), '_', ...
                     'sz-', int2str(imSize(1)), 'x', int2str(imSize(2)), '_', ...
                     cellParams.toString(cellParams)];
            if(exist([mapStr,'.mat'],'file'))
                display('loading probmap file');
                load(mapStr,'cellMapStruct');
            else
                % probMapCells: size of [ruleId,slot,loc] cell: each is an array.
                % These are the p(r|s) and p(g|r)
                [cellMapStruct] = getAllProbMapCells(cellParams,probMapStruct,ruleStruct,params,imSize);
                save(mapStr,'cellMapStruct', '-v7.3');
            end

            % centre of poses, bounds, angles used, rotated templates, etc.
            posesStruct = getPoses(params,templateStruct,imSize);

            templateStr = templateStruct.toString(templateStruct);
            % precompute
            pxStr = ['pxInds_', 'sz-', int2str(imSize(1)), 'x', int2str(imSize(2)), '_', ...
                     cellParams.toString(cellParams), '_', templateStr];
            if(exist([pxStr,'.mat'],'file'))
                display('loading pxIdxCell file');
                load(pxStr,'likePxIdxCells');
            else
                tic
                display('Starting likePxIdxCells computation');
                likePxIdxCells = cell(cellParams.nTypes,1);
                for (n=1:cellParams.nTypes)
                    likePxIdxCells{n}= getLikePxIdxAll(cellParams.centres{n}, ...
                                                       cellParams.dims(n,:), ...
                                                       posesStruct.poses{n});
                end
                display('Done likePxIdxCells computation');
                save(pxStr,'likePxIdxCells', '-v7.3');
                toc
            end 

            saveStr = [resFolder,'testSweep0', int2str(i), '_', ruleStruct.toString(ruleStruct), '_', ...
                   probMapStruct.toString(probMapStruct), '_', ...
                   params.toString(params), '_', ...
                   cellParams.toString(cellParams), '_', ...
                   'context', int2str(params.useContext), '_', ...
                   'alpha', int2str(1000*alpha), '_', ...
                   templateStr, '-selfRoot', int2str(1000000*params.probRoot), '-noise', int2str(100*templateStruct.bg), '_trial', int2str(t)];
            
            if(exist([saveStr,'.mat'],'file'))
                display(['File exists: ', saveStr]);
                continue;
            else
                [allParticles,probOn,msgs] = sampleParticlesBP(testData,posesStruct,likePxIdxCells,cellMapStruct,cellParams,params,ruleStruct,templateStruct,imSize);
                save(saveStr,'cleanTestData', 'testData', 'allParticles', 'probOn', ...
                         'templateStruct', 'probMapStruct', 'ruleStruct', 'cellParams', ...
                         'params','msgs', '-v7.3');
            end
        end
    end
end