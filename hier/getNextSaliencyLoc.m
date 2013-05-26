function [type,cellLocIdx,val,ratiosIm,stop] = getNextSaliencyLoc(particles,likesIm,countsIm,particleProbs,dirtyRegion,likePxStruct,ratiosImOld,cellParams)
    
    BOUNDARY = 1;
    
    particleUse = particles{1}; %just need one

    ratiosIm = cell(numel(particleProbs),1);
    for (i=1:numel(particleProbs))
        display(['Computing saliency on particle: ', int2str(i), ' of ', int2str(numel(particleProbs))]);
        %[likePxStruct] = evalLike(data,templateStruct,likesIm{i},countsIm{i},params);
        
        temp = evalNewLikeRatio(likesIm{i},countsIm{i},likePxStruct,dirtyRegion,ratiosImOld{i});
        ratiosIm{i} = temp;
        saliencyMap = getLogLikeCellRatio(ratiosIm{i},likePxStruct.boundaries,cellParams);


        if (i==1)
            saliencyMaps = cell(numel(saliencyMap),1);
            for (j=1:numel(saliencyMap))
                saliencyMaps{j} = log(zeros(size(saliencyMap{j})));
            end
        end
        
        for (j=1:numel(saliencyMaps))
            saliencyMaps{j} = logsum([saliencyMaps{j},saliencyMap{j}+log(particleProbs(i))],2);
        end
    end

    nTry = 0;
    nTotLoc = 0;
    for (i=1:numel(saliencyMaps))
       nTotLoc = nTotLoc + numel(saliencyMaps{i}); 
    end
    
    % #types x [value,idx]
    while(1)
        
        if (nTry >= nTotLoc)
            type = 0; cellLocIdx = 0; val = -inf; stop = 1;
            break;            
        end
        
        winners = zeros(numel(saliencyMaps),2);
        for (i=1:numel(saliencyMaps))
            [val,win] = max(saliencyMaps{i});
            winners(i,:) = [val,win];
        end
        [val,type] = max(winners(:,1));
        cellLocIdx = winners(type,2);
    
        if(val < BOUNDARY)
            stop = 1;
        else
            stop = 0;
        end
        if (any((getType(particleUse) == type) & (getLocIdx(particleUse) == cellLocIdx)))
            saliencyMaps{type}(cellLocIdx) = -Inf;
            display(['Ignoring already-found salient brick']);
            nTry = nTry + 1;
        else
            break;
        end
    end
    display(['Saliency score: ', num2str(val)]);

end