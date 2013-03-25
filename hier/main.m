startup;

params = initParams;
params.imSize = [100,100];

ruleStruct = initRules;
[poseCellLocs,cellDims,cellStrides] = initPoseCellLocs(params.imSize);
templateStruct = initTemplates;

% bricks: on/off, type, [cellCentreX,Y,Theta],[poseOffsetFromCentreX,Y,theta]
% conn{i}: children of brick i, in indices of bricks
% ruless: rule # of bricks, in reference to ruleStruct
[bricks,conn,rules] = createBricks(poseCellLocs,ruleStruct);

imBricks = viewBricks(bricks,templateStruct,params.imSize);
imshow(imBricks);

data = dataRand(params.imSize);
[like,counts] = initLike(templateStruct,data);
[likeNew,countsNew] = evalLike(data,bricks,like,counts,templateStruct);
