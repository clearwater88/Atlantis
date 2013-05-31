startup;
nTest = 10;

params = initParams;

ruleStruct = initRules;
templateStruct = initTemplates;
probMapStruct = initProbMaps(ruleStruct,templateStruct.app);

testData = cell(nTest,1);
cleanTestData = cell(nTest,1);
for (i=1:nTest)

    [cleanTestData,testData] = readData(params,templateStruct.app{end},i);
    
%     cleanTestData = zeros(size(cleanTestData));
%     cleanTestData(:,1:10:end) = 1;
%     testData = cleanTestData;
%     
    params.imSize = size(testData);
    params.imSize
    
    cellParams = initPoseCellCentres(params.imSize);    
    
    tic
    % careful with new probMap distributions
    probMapStr=toStringProbMap(params,probMapStruct);
    if(exist([probMapStr,'.mat'],'file'))
        display('loading probmap file');
        load(probMapStr);
    else
        % probMapCells: size of [ruleId,slot,loc] cell: each is an array
        [probMapCells] = getAllProbMapCells(cellParams,probMapStruct,ruleStruct,params);
        save(probMapStr,'probMapCells','-v7.3');
    end
    toc
    
    [likePxStruct] = evalLike(cleanTestData,templateStruct,zeros(size(testData)),zeros(size(testData)),params);
    
    % end is always bg
    initCounts = templateStruct.mix(end).*ones(size(testData));
    initLikes = templateStruct.mix(end)*(templateStruct.app{end}.^testData).*((1-templateStruct.app{end}).^(1-testData));
    
    saveStr = ['allRes2-', int2str(probMapStruct.strat), 'im-', int2str(i)];
    [allParticles,allLikes,allCounts,allConnPars,allConnChilds, saliencyScores] = sampleParticles(testData,likePxStruct,probMapCells,cellParams,params,ruleStruct,templateStruct);
    save(saveStr,'cleanTestData', 'testData', ...
                 'templateStruct','params', ...
                 'allParticles','allLikes','allCounts','allConnPars','allConnChilds', 'saliencyScores', '-v7.3');
end
