startup;

params = initParams;
params.imSize = [100,50];


ruleStruct = initRules;
templateStruct = initTemplates;
probMapStruct = initProbMaps(ruleStruct,templateStruct.app);

[poseCellLocs,cellDims,cellStrides] = initPoseCellLocs(params.imSize);

% tic
% %size of [ruleId,slot,loc] cell: each is an array
% [allProbMaps] = getAllProbMapCells(poseCellLocs,cellDims,probMapStruct,ruleStruct,params);
% toc;
load('allProbMaps');

% bricks: on/off, type, [cellCentreIndex],[poseOffsetFromCentreX,Y,theta]
% conn{i}: children of brick i, in indices of bricks
% ruless: rule # of bricks, in reference to ruleStruct
[bricks,conn,rules] = createBricks(poseCellLocs,ruleStruct);

imBricks = viewBricks(bricks,poseCellLocs,templateStruct,params.imSize);
imshow(imBricks);

data = dataRand(params.imSize);
[like,counts] = initLike(templateStruct,data);
%[likeNew,countsNew] = evalLike(data,bricks,like,counts,poseCellLocs,templateStruct);

probMap = allProbMaps{4,2,5};
nChildren = 2;
type = ruleStruct.children(4,2);
sampleChildren(type,probMap,nChildren,bricks);