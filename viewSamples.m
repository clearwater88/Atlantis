function viewSamples(samps,partSize,imSize)
    for (i=1:size(samps,1))
       sampUse = samps(i,:);
       sampUse(sampUse<-5) = [];
       imshow(doOutline(sampUse,partSize,imSize)); title(int2str(i));
       pause;
    end



end

