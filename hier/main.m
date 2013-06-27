function main(ds)
startup;
trainInds = 6:10;
testInd = 1:5;
nTest = numel(testInd);

params = initParams;
params.downSampleFactor = ds;

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
    
    params.imSize = size(testData);
    cellParams = initPoseCellCentres(params.imSize);
    
    % careful with new probMap distributions
    mapStr= [probMapStruct.toString(probMapStruct), '_', ...
             'sz-', int2str(params.imSize(1)), 'x', int2str(params.imSize(2)), '_', ...
             cellParams.toString(cellParams)];
    templateStr = templateStruct.toString(templateStruct);
    saveStr = ['test', int2str(i), '_', probMapStruct.toString(probMapStruct), '_', params.toString(params), '_', cellParams.toString(cellParams), '_', templateStr];
         
    if(exist([mapStr,'.mat'],'file'))
        display('loading probmap file');
        load(mapStr,'cellMapStruct');
    else
        % probMapCells: size of [ruleId,slot,loc] cell: each is an array
        [cellMapStruct] = getAllProbMapCells2(cellParams,probMapStruct,ruleStruct,params);
        save(mapStr,'cellMapStruct', '-v7.3');
    end
    
    tic
    display('Starting evalLike');
    [likePxStruct] = evalLike(testData,templateStruct,zeros(size(testData)),zeros(size(testData)),params);
    display('Done evalLike');
    toc
    
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
                                               likePxStruct.poses{n});
        end
        display('Done likePxIdxCells computation');
        save(pxStr,'likePxIdxCells', '-v7.3');
        toc
    end 
    
    [allParticles,allConnPars,allConnChilds, allParticleProbs, saliencyScores] = sampleParticles(testData,likePxIdxCells,likePxStruct,cellMapStruct,cellParams,params,ruleStruct,templateStruct);
    save(saveStr,'cleanTestData', 'testData', 'allParticleProbs', ...
                 'templateStruct', 'probMapStruct', 'cellParams', 'params', ...
                 'allParticles','allConnPars','allConnChilds', 'saliencyScores', '-v7.3');
end
end
