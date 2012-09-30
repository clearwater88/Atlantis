

imSize = [50,50];
parts(1,:) = [8,8];
parts(2,:) = [12,4];

appParam = [0.9,0.9,0.01]';
locs = getBrickLoc(imSize);
[data,gt,gtBrick] = createData(parts,appParam,imSize,locs);

learnParams(size(parts,1),data,gtBrick);