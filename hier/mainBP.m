function mainBP(ds,noiseParam,useContext)

    startup;
    trainInds = 6:10;
    testInd = 1:3;
    nTest = numel(testInd);

    params = initParams;
    params.downSampleFactor = ds;

    templateStruct = initTemplates;
    templateStruct.bg=noiseParam;

    ruleStruct = initRules(useContext);

    if(templateStruct.doLearning == 1)
       templateStruct = learnTemplates(trainInds,params,templateStruct);
    end
    probMapStruct = initProbMaps(ruleStruct,templateStruct.app);

    for (i=1:nTest)

        [cleanTestData,testData] = readData(params,templateStruct.app{end},testInd(i));

        params.imSize = size(testData);
        cellParams = initPoseCellCentres(params.imSize);

        % careful with new probMap distributions
        mapStr= [probMapStruct.toString(probMapStruct), '_', ...
                 'sz-', int2str(params.imSize(1)), 'x', int2str(params.imSize(2)), '_', ...
                 cellParams.toString(cellParams)];
        templateStr = templateStruct.toString(templateStruct);
        saveStr = ['test', int2str(i), '_', ruleStruct.toString(ruleStruct), '_', ...
                   probMapStruct.toString(probMapStruct), '_', ...
                   params.toString(params), '_', ...
                   cellParams.toString(cellParams), '_', ...
                   templateStr];

        if(exist([mapStr,'.mat'],'file'))
            display('loading probmap file');
            load(mapStr,'cellMapStruct');
        else
            % probMapCells: size of [ruleId,slot,loc] cell: each is an array.
            % These are the p(r|s) and p(g|r)
            [cellMapStruct] = getAllProbMapCells(cellParams,probMapStruct,ruleStruct,params);
            save(mapStr,'cellMapStruct', '-v7.3');
        end

        % centre of poses, bounds, angles used, rotated templates, etc.
        posesStruct = getPoses(params,templateStruct);

        % precompute
        pxStr = ['pxInds_', 'sz-', int2str(params.imSize(1)), 'x', int2str(params.imSize(2)), '_', ...
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

        
        [allParticles,probOn] = sampleParticlesBP(testData,posesStruct,likePxIdxCells,cellMapStruct,cellParams,params,ruleStruct,templateStruct);
        save(saveStr,'cleanTestData', 'testData', 'allParticles', 'probOn', ...
                 'templateStruct', 'probMapStruct', 'ruleStruct', 'cellParams', ...
                 'params', '-v7.3');


    end
end