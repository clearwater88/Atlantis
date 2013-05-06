function [type,cellLocIdx,val,stop] = getNextSaliencyLoc(data,particles,likesIm,countsIm,particleProbs,templateStruct,cellParams,params)

    BOUNDARY = -2;

    %type = randi(numel(saliencyMap),1,1);
    %cellLocIdx = randi(numel(saliencyMap{type}),1,1);
    
    particleUse = particles{1}; %just need one

    for (i=1:numel(particleProbs))
        display(['Computing saliency on particle: ', int2str(i), ' of ', int2str(numel(particleProbs))]);
        [likePxStruct] = evalLike(data,templateStruct,params,likesIm{i},countsIm{i});
        
        saliencyMap = getLogLikeCell(likePxStruct,cellParams);
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

    % #types x [value,idx]
    while(1)
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
        else
            break;
        end
    end
    display(['Saliency score: ', num2str(val)]);

end