function viewAllRes(cleanData, data,allParticles,probOn,cellParams,templateStruct,params)
    close all;
    
    nTypes = numel(probOn{1});

    y = cleanData(:);
    tp = zeros(numel(data),numel(probOn));
    fp = zeros(numel(data),numel(probOn));
    auc = zeros(numel(probOn),1);
    
    [rotTemplates,~] = getRotTemplates(params,templateStruct);
    
%     for (i=1:numel(probOn))
%         probPixel = viewAllParticles(allParticles{i},rotTemplates,params);
%         [tp(:,i),fp(:,i),auc(i)] = getROC(probPixel(:),y);
%     end
%     figure(88);
%     plot(fp(:,end),tp(:,end),'o-'); hold on; plot(0:0.1:1,0:0.1:1,'r');
%     xlabel('false positive');
%     ylabel('true positive');
%     title(['ROC curve at final iteration. AUC: ', num2str(auc(end))]);
% 
%     figure(90);
%     plot(1:numel(auc),auc,'o-');
%     xlabel('# active bricks');
%     ylabel('AUC of ROC');
%     title(['Average ROC curve']);
    
    %for (i=1:numel(probOn))
    for(i=numel(probOn))
        on = probOn{i};
        particle = allParticles{i};
        sOn = getProbOn(particle);
        % suppress already known
        for (n=1:nTypes)
            inds = sOn(1,:)==n;
            locs = sOn(2,inds);
            on{n}(locs) = 0;
        end
        
        figure(99); subplot(1,3,1); imshow(data);
        st = viewAllParticles(particle,rotTemplates,params);
        subplot(1,3,2); imshow(st);
        subplot(1,3,3); imshow(cleanData);
        
        viewHeatMap(sOn,on,cellParams,params.imSize,1000)
        
        figure(2000); title(int2str(i));
        for (n=1:nTypes)
            subplot(nTypes,1,n); plot(on{n}); 
        end

%         for (n=1:nTypes)
%            display(['avg prob on: ', num2str(mean(on{n}))]);
%         end
        
        pause(0.5);
        
        
        
    end


end

