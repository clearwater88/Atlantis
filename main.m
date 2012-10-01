

imSize = [100,100];

params = initParams;

appParam = [0.5,0.95,0.01]';

locs = getBrickLoc(imSize,params);
[data,gt,gtBrick] = createData(params,appParam,imSize,locs);

qParts = learnParams(params,data,gtBrick);