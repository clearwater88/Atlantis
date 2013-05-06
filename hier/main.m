startup;
dataFolder = '../BSDSdata/';
nTest = 10;

params = initParams;

ruleStruct = initRules;
templateStruct = initTemplates;
probMapStruct = initProbMaps(ruleStruct,templateStruct.app);

testData = cell(nTest,1);
cleanTestData = cell(nTest,1);
for (i=8:nTest)

    downSampFact = 8;
    cleanTestData{i} = im2double(imread([dataFolder, 'test', int2str(i), '.jpg']));
    cleanTestData{i} = cleanTestData{i}<0.5;
    cleanTestData{i} = bwmorph(cleanTestData{i},'dilate',log2(downSampFact));
    cleanTestData{i} = imresize(cleanTestData{i},1/downSampFact,'nearest');
    
    bg = find(cleanTestData{i}==0);
    testDataTemp = cleanTestData{i};
    for (j=1:numel(bg))
        testDataTemp(bg(j)) = rand(1,1) < templateStruct.app{end}; %background model
    end
    testData{i} = testDataTemp;

    params.imSize = size(testData{i});
    cellParams = initPoseCellCentres(params.imSize);

    %probMapCells: size of [ruleId,slot,loc] cell: each is an array
    [probMapCells] = getAllProbMapCells(cellParams,probMapStruct,ruleStruct,params);

    %data = dataRand(params.imSize);

    [likePxStruct] = evalLike(testData{i},templateStruct,params);
    % save('likePxStruct','likePxStruct');
    % load('likePxStruct');

    [allParticles{i},allParticleProbs{i},allLikes{i},allCounts{i},allConnPars{i},allConnChilds{i}, saliencyScores{i}] = sampleParticles(testData{i},likePxStruct,probMapCells,cellParams,params,ruleStruct,templateStruct);
    save('allRes','allParticles','allParticleProbs','allLikes','allCounts','allConnPars','allConnChilds', 'saliencyScores', '-v7.3');
end
