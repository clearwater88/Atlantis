function viewSamples(samps,partSize,imSize,totalPost,qParts)
    for (i=1:size(samps,1))
       sampUse = samps(i,:);
       sampUse(sampUse<-5) = [];
       nSampOn = numel(sampUse)/4;
       imshow(doOutline(sampUse,partSize,imSize,qParts));
       %imshow(doOutline(sampUse,partSize,imSize));
       title(sprintf('%d: %d, prob: %f', i, nSampOn,totalPost(i)));
       pause;
    end
end

