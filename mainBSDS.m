params = initParams;
dataFolder = 'BSDSdata/';

%must be odd
szs = [5,9];
params.partMix = params.mixPropFact*(max(szs)./(szs) - 1) + 1;

nParts = numel(szs);
qParts = cell(nParts+1,1);
% bg model
qParts{end} = 0.2;

for (i=1:numel(szs))
    temp = 0.8*ones(szs(i),1);
    temp(temp == -1) = qParts{end};
    qParts{i} = temp;
    params.partSizes(i,:) = (size(qParts{i})-1)/2;
end


nTest = 2;

totalPost = cell(nTest,1);
samp_x = cell(nTest,1);
counts = cell(nTest,1);
like = cell(nTest,1);

testData = cell(nTest,1);
cleanTestData = cell(nTest,1);

for (i=1:nTest)

    downSampFact = 8;
    cleanTestData{i} = im2double(imread([dataFolder, 'test', int2str(i), '.jpg']));
    cleanTestData{i} = cleanTestData{i}<0.5;
    cleanTestData{i} = bwmorph(cleanTestData{i},'dilate',log2(downSampFact));
    cleanTestData{i} = imresize(cleanTestData{i},1/downSampFact,'nearest');
    
    bg = find(cleanTestData{i}==0);
    testDataTemp = cleanTestData{i};
    for (j=1:numel(bg))
        testDataTemp(bg(j)) = rand(1,1) < qParts{end};
    end
    testData{i} = testDataTemp;
    
    imSize = [size(testData{i},1),size(testData{i},2)];

    display(sprintf('On image %d of %d', i, nTest));
    [totalPost{i},samp_x{i},counts{i},like{i}] = infer(testData{i},cleanTestData{i},qParts,params);
    
%     'showing'
%     figure(101); imshow(cleanTestData);
%     figure(201); imshow(testData{i});
%     figure(301); viewSamples(samp_x{i},params.partSizes,imSize,totalPost{i},qParts);
end
save('resBSDS');