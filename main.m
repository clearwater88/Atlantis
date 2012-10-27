

imSize = [50,50];

params = initParams;

appParam = cell(2,1);

appParam{1} = [1,   1,   1,   1,   1; ...
               0.2, 0.2, 0.2, 0.2, 0.2; ...
               0.8, 0.8, 0.8, 0.8, 0.8; ...
               0.2, 0.2, 0.2, 0.2, 0.2; ...
               0.8, 0.8, 0.8, 0.8, 0.8; ...
               0.2, 0.2, 0.2, 0.2, 0.2; ...
               0.8, 0.8, 0.8, 0.8, 0.8; ...
               0.2, 0.2, 0.2, 0.2, 0.2; ...
               0.8, 0.8, 0.8, 0.8, 0.8; ...
               0.2, 0.2, 0.2, 0.2, 0.2; ...
               0.8, 0.8, 0.8, 0.8, 0.8; ...
               0.2, 0.2, 0.2, 0.2, 0.2; ...
               0.8, 0.8, 0.8, 0.8, 0.8; ...
               0.2, 0.2, 0.2, 0.2, 0.2; ...
               0.8, 0.8, 0.8, 0.8, 0.8; ...
               0.2, 0.2, 0.2, 0.2, 0.2; ...
               1,   1,   1,   1,   1];


% appParam{2} = [0.5, 0.5, 0.5, 0.5, 0.5; ...
%                0.5, 0.5, 0.9, 0.5, 0.5; ...
%                0.5, 0.9, 0.9, 0.9, 0.5; ...
%                0.5, 0.5, 0.9, 0.5, 0.5; ...
%                0.5, 0.5, 0.5, 0.5, 0.5];
% 
%  appParam{3} = [0.8, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.8; ...
%                 0.1, 0.8, 0.1, 0.1, 0.1, 0.1, 0.1, 0.8, 0.1; ...
%                 0.1, 0.1, 0.8, 0.1, 0.1, 0.1, 0.8, 0.1, 0.1; ...
%                 0.1, 0.1, 0.1, 0.8, 0.1, 0.8, 0.1, 0.1, 0.1; ...
%                 0.1, 0.1, 0.1, 0.1, 0.8, 0.1, 0.1, 0.1, 0.1; ...
%                 0.1, 0.1, 0.1, 0.8, 0.1, 0.8, 0.1, 0.1, 0.1; ...
%                 0.1, 0.1, 0.8, 0.1, 0.1, 0.1, 0.8, 0.1, 0.1; ...
%                 0.1, 0.8, 0.1, 0.1, 0.1, 0.1, 0.1, 0.8, 0.1; ...
%                 0.8, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.8];
            
% appParam{1} = 1;
% appParam{2} = 1;
% appParam{3} = 1;

appParam{end} = 0.1;
           
locs = getBrickLoc(imSize,params);
[data,gtBrick] = createData(params,appParam,imSize,locs);

trainData = data(:,:,1:floor(end/2));
gtBrickTrain = gtBrick(1:floor(end/2),:,:,:);

testData = data(:,:,floor(end/2)+1:end);
gtBrickTest = gtBrick(floor(end/2)+1:end,:,:,:);

qParts = learnParams(params,trainData,gtBrick);

% HACK FOR BACKGROUND FOR NOW
qParts{end+1} = appParam{end};

save('temp','qParts','trainData','testData','gtBrickTrain','gtBrickTest');
load('temp');


imSize = [size(data,1),size(data,2)];
nTest = size(testData,3);

totalLike = zeros([params.postParticles, nTest]);
samp_x = cell(nTest,1);
counts = zeros([imSize,params.postParticles,nTest]);
likeFg = zeros([imSize,params.postParticles,nTest]);

tic
for (i=1:nTest)
    display(sprintf('On image %d of %d', i, nTest));
    [totalLike(:,i),samp_x{i},counts(:,:,:,i),like(:,:,:,i)] = infer(testData(:,:,i),qParts,locs,params);
    
%     figure(1); imshow(testData(:,:,i));
%     figure(2); viewSamples(samp_x{i},params.partSizes,imSize);
end
toc
save('res3');