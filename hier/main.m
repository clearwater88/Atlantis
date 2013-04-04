startup;

params = initParams;
params.imSize = [80,40];


ruleStruct = initRules;
templateStruct = initTemplates;
probMapStruct = initProbMaps(ruleStruct,templateStruct.app);

[poseCellLocs,cellDims,cellStrides] = initPoseCellLocs(params.imSize);

% tic
% %size of [ruleId,slot,loc] cell: each is an array
% [allProbMaps] = getAllProbMapCells(poseCellLocs,cellDims,probMapStruct,ruleStruct,params);
% toc;
% save('allProbMaps','allProbMaps');
load('allProbMaps');

% bricks: on/off, type, [cellCentreIndex],[poseOffsetFromCentreX,Y,theta]
% connChild{i}: children of brick i, in indices of all bricks in bricks
% connParr{i}: parents of brick i, in indices of all bricks in bricks
% ruless: rule # of bricks, in reference to ruleStruct
[bricks,connChild,connParr,rules] = createBricks(allProbMaps,poseCellLocs,ruleStruct);

imBricks = viewBricks(bricks,poseCellLocs,templateStruct,params.imSize);
imshow(imBricks);

data = dataRand(params.imSize);
[like,counts] = initLike(templateStruct,data);
%[likeNew,countsNew] = evalLike(data,bricks,like,counts,poseCellLocs,templateStruct);
% 
% ruleId = 4;
% parentLocInd = 5;
% slot=2;
% sampleChildren(parentLocInd,ruleId,slot,allProbMaps,bricks,ruleStruct);