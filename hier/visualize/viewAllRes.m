function viewAllRes(data,allParticles,probOn,cellParams,templateStruct,params)

    nTypes = numel(probOn{1});

    for (i=1:numel(probOn))
        on = probOn{i};
        particle = allParticles{i};
        % suppress already known
        for (n=1:nTypes)
            on{n}(on{n}>0.999) = 0;
        end
        
        figure(1); subplot(1,2,1); imshow(data);
        st = viewAllParticles(particle,templateStruct,params);
        subplot(1,2,2); imshow(st);
        
        figure(1000); title(int2str(i));
        viewHeatMap(on,cellParams);
        
        figure(2000); title(int2str(i));
        for (n=1:nTypes)
            subplot(nTypes,1,n); plot(on{n}); 
        end
        pause;
    end


end

