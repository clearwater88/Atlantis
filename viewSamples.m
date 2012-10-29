function viewSamples(samps,partSize,imSize,totalPost)
    for (i=1:size(samps,1))
       sampUse = samps(i,:);
       sampUse(sampUse<-5) = [];
       nSampOn = numel(sampUse)/3;
       imshow(doOutline(sampUse,partSize,imSize));
       title(sprintf('%d: %d, prob: %f', i, nSampOn,totalPost(i)));
       pause;
    end



end

