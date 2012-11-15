params = initParams;

%must be odd
szs = [5,9,13];
params.partMix = params.mixPropFact*(max(szs)./(szs) - 1) + 1;

nParts = numel(szs);
qParts = cell(nParts+1,1);
% bg model
qParts{end} = 0.2;

for (i=1:numel(szs))
    temp = 0.9*ones(szs(i),1);
    temp(temp == -1) = qParts{end};
    qParts{i} = temp;
    params.partSizes(i,:) = (size(qParts{i})-1)/2;
end


nTest = 10;

totalPost = cell(nTest,1);
samp_x = cell(nTest,1);
counts = cell(nTest,1);
like = cell(nTest,1);
testData = cell(nTest,1);

for (i=1:nTest)

    downSampFact = 8;
    cleanTestData = im2double(imread(['test', int2str(i), '.jpg']));
    cleanTestData = cleanTestData<0.5;
    cleanTestData = bwmorph(cleanTestData,'dilate',log2(downSampFact));
    cleanTestData = imresize(cleanTestData,1/downSampFact,'nearest');
    
    bg = find(cleanTestData==0);
    testDataTemp = cleanTestData;
    for (j=1:numel(bg))
        testDataTemp(bg(j)) = rand(1,1) < qParts{end};
    end
    testData{i} = testDataTemp;
    
    imSize = [size(testData{i},1),size(testData{i},2)];

    display(sprintf('On image %d of %d', i, nTest));
    [totalPost{i},samp_x{i},counts{i},like{i}] = infer(testData{i},qParts,params);
    
    'showing'
    figure(101); imshow(cleanTestData);
    figure(201); imshow(testData{i});
    figure(301); viewSamples(samp_x{i},params.partSizes,imSize,totalPost{i},qParts);
end
save('resBSDS');