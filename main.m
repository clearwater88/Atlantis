

imSize = [50,50];

params = initParams;

appParam = cell(2,1);

appParam{1} = [1, 1, 1; ...
               0, 0, 0; ...
               1, 1, 1; ...
               0, 0, 0; ...
               1, 1, 1; ...
               0, 0, 0; ...
               1, 1, 1;
               0, 0, 0; ...
               1, 1, 1;
               0, 0, 0; ...
               1, 1, 1;
               0, 0, 0; ...
               1, 1, 1;
               0, 0, 0; ...
               1, 1, 1];


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

appParam{end} = 0.01;
           
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

% clear them out a bit
locs(mod(locs(:,1),3) ~= 0,:) = [];
locs(mod(locs(:,2),3) ~= 0,:) = [];

imSize = [size(data,1),size(data,2)];
nTest = size(testData,3);

totalLike = zeros([params.postParticles, nTest]);
samp_x = zeros([params.postParticles,size(locs,1)*3,nTest]);
counts = zeros([imSize,params.postParticles,nTest]);
likeFg = zeros([imSize,params.postParticles,nTest]);

for (i=1:nTest)
    display(sprintf('On image %d of %d', i, nTest));
    [totalLike(:,i),samp_x(:,:,i),counts(:,:,:,i),likeFg(:,:,:,i)] = infer(testData(:,:,i),qParts,locs,params);
end
save('res2');