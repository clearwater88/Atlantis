startup;
trainInds = 6:10;
testInd = 1:5;
nTest = numel(testInd);

params = initParams;
ruleStruct = initRules;
templateStruct = initTemplates;

if(templateStruct.doLearning == 1)
    templateStruct = learnTemplates(trainInds,params,templateStruct);
end
% trainData{1} = zeros([40,60]);
% trainData{1}(:,1:10:end) = 1;

probMapStruct = initProbMaps(ruleStruct,templateStruct.app);

for (i=1:nTest)
    
    [cleanTestData,testData] = readData(params,templateStruct.app{end},testInd(i));
    %testData=cleanTestData;
    
    params.imSize = size(testData);
    cellParams = initPoseCellCentres(params.imSize);
    
    % careful with new probMap distributions
    mapStr= [probMapStruct.toString(probMapStruct), '_', ...
             'sz-', int2str(params.imSize(1)), 'x', int2str(params.imSize(2)), '_', ...
             cellParams.toString(cellParams)];
    templateStr = templateStruct.toString(templateStruct);
    saveStr = ['test', int2str(i), '_', mapStr, '_', templateStr;];
         
    if(exist([mapStr,'.mat'],'file'))
        display('loading probmap file');
        load(mapStr);
    else
        % probMapCells: size of [ruleId,slot,loc] cell: each is an array
        [probMapCells] = getAllProbMapCells(cellParams,probMapStruct,ruleStruct,params);
        save(mapStr,'probMapCells','-v7.3');
    end
    
    [allParticles,allConnPars,allConnChilds, saliencyScores] = sampleParticles(testData,probMapCells,cellParams,params,ruleStruct,templateStruct);
    save(saveStr,'cleanTestData', 'testData', ...
                 'templateStruct','params', ...
                 'allParticles','allConnPars','allConnChilds', 'saliencyScores', '-v7.3');
end
