function [type,cellLoc] = getNextSaliencyLoc(saliencyMap,particles)

    maxs = zeros(numel(saliencyMap),1);
    ids = zeros(numel(saliencyMap),1);

    while(1)
    
        for (t=1:numel(saliencyMap))
           mp = saliencyMap{t};
           [tempMax,tempId] = max(mp);
           maxs(t) = tempMax;
           ids(t) = tempId;

        end

        [~,type] = max(maxs);
        cellLoc = ids(type);
        
        if(isempty(particles))
           break; 
        end
        
        if(any(particles(1,:) == 1) && ... %particle on
           any(particles(2,:) == type) && ...  % right type
           any(particles(3,:) == cellLoc)) % right location
      
            saliencyMap{t}(cellLoc) = -Inf;
        else
            break;
        end
        
    end

end