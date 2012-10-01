

imSize = [100,100];

params = initParams;

appParam = [0.9,0.9,0.01]';

locs = getBrickLoc(imSize);
[data,gt,gtBrick] = createData(params.partSizes,appParam,imSize,locs);

learnParams(params,data,gtBrick);