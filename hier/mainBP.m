function mainBP(ds,noiseParam,useContext,alpha,resFolder,nStart,nTrials)
% mainBP(16,0.1,1,1,'resTemp/',0,1);
    if(isempty(resFolder))
        resFolder = 'res/';
    end
    if(isempty(alpha))
        alpha = 100;
    end
    alpha = alpha/100; % stupid cluster thing
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
        ruleStruct = initRules();
        probMapStruct = initProbMaps(ruleStruct,templateStruct.sizes);

        [templateStruct,probMapStruct,ruleStruct] = doLearning(trainInds,params,ruleStruct,templateStruct,probMapStruct);
%         save('learning2', 'templateStruct','probMapStruct','ruleStruct', '-v7.3');
        % inference
        
        save(['genDataEx/templateBSDS', int2str(noiseParam*100)], 'templateStruct');
        
%         for (i=1:numel(testInds))
%             [cleanData,data] = readData(params,templateStruct.app{end},testInds(i));
%             imSize = size(data);
%             cellParams = initPoseCellCentres(imSize,templateStruct.sizes);
%     
%             selfRootStr = 'selfRoot';
%             for (j=1:numel(params.probRoot))
%                 selfRootStr = [selfRootStr, '-', int2str(1000000*params.probRoot(j))];
%             end
%             
%             saveStr = [resFolder,'testSweep', int2str(testInds(i)), '_', ...
%                        'imSize', int2str(imSize(1)),'-',int2str(imSize(2)), '_', ...
%                        ruleStruct.toString(ruleStruct), '_', ...
%                        probMapStruct.toString(probMapStruct), '_', ...
%                        params.toString(params), '_', ...
%                        cellParams.toString(cellParams), '_', ...
%                        'context', int2str(params.useContext), '_', ...
%                        'alpha', int2str(100*alpha), '_', ...
%                        templateStruct.toString(templateStruct), '-', ...
%                        selfRootStr, ...
%                        '_noise', int2str(100*templateStruct.bg), ...
%                        '_trial', int2str(t)];
%                    
%             if(exist([saveStr,'.mat'],'file'))
%                 display(['File exists: ', saveStr]);
%             else
%                 [allParticles,probOn,probOnFinal,msgs] = doInfer(data,params,ruleStruct,templateStruct,probMapStruct,cellParams,imSize);
%                 finalParticles = allParticles{end};
%                 save(saveStr,'cleanData', 'data', 'allParticles', 'probOn', ...
%                     'templateStruct', 'probMapStruct', 'ruleStruct', 'cellParams', ...
%                     'params','msgs', 'finalParticles','ruleStruct','probOnFinal','-v7.3');
%             end
% 
%         end
    end
end