startup;

params = initParams;
params.imSize = [100,100];

ruleStruct = initRules;
[poseCellLocs,cellDims,cellStrides] = initPoseCellLocs(params.imSize);
templateStruct = initTemplates;

% on/off, type, [cellCentreX,Y,Theta],[poseOffsetFromCentreX,Y,theta]
[bricks,conn] = createBricks(poseCellLocs);

imBricks = viewBricks(bricks,templateStruct,params.imSize);
imshow(imBricks);

data = dataRand(params.imSize);
[like,counts] = initLike(templateStruct,data);
[likeNew,countsNew] = evalLike(data,bricks,like,counts,templateStruct);
