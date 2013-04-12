startup;

params = initParams;
params.imSize = [80,40];

data = dataRand(params.imSize);

ruleStruct = initRules;
templateStruct = initTemplates;
probMapStruct = initProbMaps(ruleStruct,templateStruct.app);

[cellCentres,cellDims,cellStrides] = initPoseCellLocs(params.imSize);

% tic
% %size of [ruleId,slot,loc] cell: each is an array
% [allProbMaps] = getAllProbMapCells(cellCentres,cellDims,probMapStruct,ruleStruct,params);
% toc;
% save('allProbMaps','allProbMaps');
load('allProbMaps');


initParticles{1} = [];
particleProbs  = 1;
[likeTemp,countsTemp] = initLike(templateStruct,data);

like{1} = likeTemp;
counts{1} = countsTemp;

[likePx,boundariesPx,countsPx] = evalLike(data,templateStruct,params);


[pose,poseOffset] = samplePose(cellType,centreIdx,cellCentres,cellDims,boundariesPx,likePx,countsPx);
 
%sampleParticles(initParticles,particleProbs,like,counts,allProbMaps);

% bricks: on/off, type, [cellCentreIndex],[poseOffsetFromCentreX,Y,theta]
% connChild{i}: children of brick i, in indices of all bricks in bricks
% connParr{i}: parents of brick i, in indices of all bricks in bricks
%[bricks,connChild,connPar] = createBricks(allProbMaps,poseCellLocs,ruleStruct,params.probRoot);
% 
% %imBricks = viewBricks(bricks,poseCellLocs,templateStruct,params.imSize);
% %imshow(imBricks);
% % 
% 
% [like,counts] = initLike(templateStruct,data);
