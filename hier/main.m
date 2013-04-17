startup;

params = initParams;
params.imSize = [30,20];

ruleStruct = initRules;
templateStruct = initTemplates;
probMapStruct = initProbMaps(ruleStruct,templateStruct.app);

cellParams = initPoseCellLocs(params.imSize);

% tic
% %allProbMapCells: size of [ruleId,slot,loc] cell: each is an array
% [allProbMapCells] = getAllProbMapCells(cellParams,probMapStruct,ruleStruct,params);
% toc;
% save('allProbMaps','allProbMaps');
load('allProbMaps');


sampleParticles(data,allProbMapCells,cellParams,params,ruleStruct,templateStruct);










% 
% cellType = 1;
% centreIdx = 22;
% 
% pose = samplePose(like{1},counts{1}, ...
%                   likePxStruct, ...
%                   cellType,centreIdx,cellCentres,cellDims,params);
              

              
%sampleParticles(initParticles,particleProbs,like,counts,allProbMaps);

% bricks: on/off, type, cellCentreIndex,[poseX,Y,theta]
% connChild{i}: children of brick i, in indices of all bricks in bricks
% connParr{i}: parents of brick i, in indices of all bricks in bricks
%[bricks,connChild,connPar] = createBricks(allProbMaps,poseCellLocs,ruleStruct,params.probRoot);
% 
% %imBricks = viewBricks(bricks,poseCellLocs,templateStruct,params.imSize);
% %imshow(imBricks);
% % 
% 
% [like,counts] = initLike(templateStruct,data);
