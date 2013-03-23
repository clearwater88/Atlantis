function viewSamples(samps,testData,cleanTestData,params,imSize,totalPost,qParts)
%     for (i=1:size(samps,1))
%        sampUse = samps(i,:);
%        sampUse(sampUse<-5) = [];
%        nSampOn = numel(sampUse)/4;
%        imshow(doOutline(sampUse,partSize,imSize,qParts));
%        %imshow(doOutline(sampUse,partSize,imSize));
%        title(sprintf('%d: %d, prob: %f', i, nSampOn,totalPost(i)));
%        pause;
%     end

    subplot(2,2,1);
    imshow(cleanTestData);

    subplot(2,2,2);
    imshow(testData);

    for (j=1:size(samps,1))
       sampUse = samps(j,:);       
       sampUse(sampUse<-5) = [];
       nSampOn = numel(sampUse)/4;
       outline = doOutline(sampUse,params.partSizes,imSize,qParts);
       subplot(2,2,3);
       imshow(outline);
       title(sprintf('Partice %d, %d bricks on, prob: %f', j,nSampOn,totalPost(j)));
       
       outlineInTest = testData & outline;
       outlineNotInTest = ~testData & outline;
       
       outlineTest(:,:,1) = double(outlineInTest);
       outlineTest(:,:,2) = double(outlineNotInTest);
       outlineTest(:,:,3) = zeros(size(outlineTest(:,:,1)));
       outlineTest = double(outlineTest);
       
       save('debug');
       subplot(2,2,4);
       
       imshow(outlineTest);
       
       pause;
    end

end
