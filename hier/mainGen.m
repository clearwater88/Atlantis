function mainGen(imSize, noiseParam, useContext,resFolder,nStart,nTrials)
% mainGen([50,50], 0.1,1,'resTemp/',0,1);
    startup;
    
    genFolder = 'genDataEx/';
    genStr= [genFolder,'ex%d_imSize', int2str(imSize(1)), '-', int2str(imSize(2)), ...
               '_', 'noiseParam-', int2str(noiseParam)] ;
           
    if(isempty(resFolder))
        resFolder = 'resDataEx/';
    end
    [~,~]=mkdir(resFolder);

    %[trainInds,testInds] = splitData(10,0.5,0.5);
    %trainInds = [1:5];
    testInds=[1:5];
    
%     params.downSampleFactor = ds;
%     params.useContext = useContext;
%     params.alpha = alpha;
    
    for (t=nStart:nStart+nTrials-1)
       
        % inference
        for (i=1:numel(testInds))
            
            load(sprintf(genStr,testInds(i)),'probPixel', 'mask', 'data', 'cleanData','ruleStruct','probMapStruct','templateStruct','ruleStruct','params');
            
            params2 = initParams;
            % set defaults
            params2.useContext=useContext;
            params2.alpha = 1;
            %copy over
            params2.downSampleFactor = params.downSampleFactor;
            params2.probRoot = params.probRoot;
            params=params2; clear params2;

            testData = data;
            
            imSize = size(testData);
            cellParams = initPoseCellCentres(imSize,templateStruct.sizes);
    
            selfRootStr = 'selfRoot';
            for (j=1:numel(params.probRoot))
                selfRootStr = [selfRootStr, '-', int2str(1000000*params.probRoot(j))];
            end
            
            saveStr = [resFolder,'testSweep', int2str(testInds(i)), '_', ...
                       'imSize', int2str(imSize(1)),'-',int2str(imSize(2)), '_', ...
                       ruleStruct.toString(ruleStruct), '_', ...
                       probMapStruct.toString(probMapStruct), '_', ...
                       params.toString(params), '_', ...
                       cellParams.toString(cellParams), '_', ...
                       'context', int2str(params.useContext), '_', ...
                       'alpha', int2str(100*params.alpha), '_', ...
                       templateStruct.toString(templateStruct), '-', ...
                       selfRootStr, ...
                       '_noise', int2str(100*templateStruct.bg), ...
                       '_trial', int2str(t)];
                   
            if(exist([saveStr,'.mat'],'file'))
                display(['File exists: ', saveStr]);
            else
                [allParticles,probOn,probOnFinal,msgs] = doInfer(testData,params,ruleStruct,templateStruct,probMapStruct,cellParams,imSize);
                finalParticles = allParticles{end};
                save(saveStr,'cleanData', 'data', 'allParticles', 'probOn', ...
                    'templateStruct', 'probMapStruct', 'ruleStruct', 'cellParams', ...
                    'params','msgs', 'finalParticles','ruleStruct','probOnFinal','-v7.3');
            end

        end
    end
end