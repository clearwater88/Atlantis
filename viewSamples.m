function viewSamples(samps,partSize,imSize)
    for (i=1:size(samps,1))
       sampUse = samps(i,:);
       sampUse(sampUse<-5) = [];
       nSampOn = numel(sampUse)/3;
       imshow(doOutline(sampUse,partSize,imSize));
       title(sprintf('%d: %d', i, nSampOn));
       pause;
    end



end

