function [totalLike,samp_x,counts,like] = infer(data,qParts,locs,params)


    partSize =  params.partSizes(1,:);
    
    % For now, iterate in order
    
    bg = qParts{end};
    
    like = params.bgMix*((bg.^data).*((1-bg).^(1-data)));
    counts = params.bgMix*ones(size(data));
    samp_x = [];
    totalLike = 1;
    
    salient = getSaliencyMap(data,qParts);
    [salientLocs,locsScore] = orderSalient(salient,locs);
    
    goodLocs = locsScore>params.salientLogThresh;
    salientLocs = salientLocs(goodLocs,:);
    
    MAXP = size(salientLocs,1);
    assert(MAXP > 1);
    
  %  figure(1); imshow(data);
    for (i=1:MAXP)
        display(sprintf('%d / %d',i,MAXP));
        [totalLike,samp_x,counts,like] = ...
            samplePosterior(params, data,qParts,partSize,salientLocs(i,:), ...
<<<<<<< HEAD
                            totalLike,like,samp_x,counts);
=======
                            totalLike,likeFg,samp_x,counts);
%         figure(2);
%         samp = samp_x(1,:);
%         samp(samp<-3) = [];
%         ot= doOutline(samp,params.partSizes,[size(data,1),size(data,2)]);
%         figure(2); imshow(ot); title(int2str(i));
%         pause;
>>>>>>> parent of a22258e... preparing code for keeping up-to-date saliency maps
    end

end


