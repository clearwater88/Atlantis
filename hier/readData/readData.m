function [cleanTestData, testData] = readData(params,bgProb,n)

    cleanTestData = im2double(imread([params.dataFolder, 'test', int2str(n), '.jpg']));
    cleanTestData = cleanTestData(2:end-1,2:end-1);
    
    cleanTestData = cleanTestData<0.5;
    cleanTestData = bwmorph(cleanTestData,'dilate',log2(params.downSampleFactor));
    cleanTestData = imresize(cleanTestData,1/params.downSampleFactor,'nearest');
    
    bg = find(cleanTestData==0);
    testDataTemp = cleanTestData;
    for (j=1:numel(bg))
        testDataTemp(bg(j)) = rand(1,1) < bgProb; %background model
    end
    testData = testDataTemp;
end

