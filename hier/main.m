startup;

params = initParams;
params.imSize = [200,100];


ruleStruct = initRules;
templateStruct = initTemplates;
probMapStruct = initProbMaps(ruleStruct,templateStruct.app);

[poseCellLocs,cellDims,cellStrides] = initPoseCellLocs(params.imSize);

[probMapCells,probMapPixels] = getProbMapCells(3,1,poseCellLocs{1}(100,:),probMapStruct,ruleStruct,params.imSize,params.angleDisc,poseCellLocs,cellDims);


% bricks: on/off, type, [cellCentreX,Y,Theta],[poseOffsetFromCentreX,Y,theta]
% conn{i}: children of brick i, in indices of bricks
% ruless: rule # of bricks, in reference to ruleStruct
[bricks,conn,rules] = createBricks(poseCellLocs,ruleStruct);

imBricks = viewBricks(bricks,templateStruct,params.imSize);
imshow(imBricks);

data = dataRand(params.imSize);
[like,counts] = initLike(templateStruct,data);
[likeNew,countsNew] = evalLike(data,bricks,like,counts,templateStruct);
