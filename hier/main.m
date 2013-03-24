params = initParams;
params.imSize = [100,100];

ruleStruct = initRules;
[poseCellLocs,cellDims,cellStrides] = initPoseCellLocs(params.imSize);
templateStruct = initTemplates;

% 5 bricks, all on
% on/off, type,rule, [cellCentreX,Y,Theta],[poseOffsetFromCentreX,Y,theta]
nBricks = 5000;
bricks = ones(1,nBricks);
bricks(2,:) = 1; % type 1 brick
bricks(3,:) = -1; %rule doesn't matter right now
randInds = randi(size(poseCellLocs{1},1),nBricks,1);
bricks(4:6,:) = poseCellLocs{1}(randInds,:)';
bricks(7:8,:) = round(2*rand(2,nBricks)-1); % round offsets to integer
bricks(9,:) = mod(0.1*randn(1,nBricks),2*pi);

imBricks = viewBricks(bricks,templateStruct,params.imSize);
imshow(imBricks);

%data = dataRand(params.imSize);
%[like,counts] = initLike(templateStruct,data);
%[likeNew,countsNew] = evalLike(data,bricks,like,counts,templateStruct);
