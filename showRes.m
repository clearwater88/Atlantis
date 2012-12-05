dataFolder = 'BSDSdata/';
nTest = 2;

for (i=1:nTest)
    cleanTestData = im2double(imread([dataFolder,'test', int2str(i), '.jpg']));
    cleanTestData = cleanTestData<0.5;
    cleanTestData = bwmorph(cleanTestData,'dilate',log2(downSampFact));
    cleanTestData = imresize(cleanTestData,1/downSampFact,'nearest');
    imSize = [size(testData{i},1),size(testData{i},2)];

    subplot(2,2,1);
    imshow(cleanTestData);

    subplot(2,2,2);
    imshow(testData{i});

    samps = samp_x{i};
    totalPostSamp = totalPost{i};
    for (j=1:size(samps,1))
       sampUse = samps(j,:);       
       sampUse(sampUse<-5) = [];
       nSampOn = numel(sampUse)/4;
       outline = doOutline(sampUse,params.partSizes,imSize,qParts);
       title(sprintf('%d: %d, prob: %f', i, nSampOn,totalPostSamp(j)));
       subplot(2,2,3);
       imshow(outline);
       
       outlineInTest = testData{i} & outline;
       outlineNotInTest = ~testData{i} & outline;
       
       outlineTest(:,:,1) = outlineInTest;
       outlineTest(:,:,2) = outlineNotInTest;
       outlineTest(:,:,3) = zeros(size(outlineTest(:,:,1)));
       outlineTest = double(outlineTest);
       
       subplot(2,2,4);
       imshow(outlineTest);
       
       pause;
    end
    %viewSamples(samp_x{i},params.partSizes,imSize,totalPost{i},qParts);
end;