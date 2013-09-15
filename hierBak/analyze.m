function allAuc = analyze()

    resFolder = 'res_sweep2/';
    %resFile = 'testSweep01__probMap-cov4x1_4x1_4x1_4x1__ds4_cell-dims7_7_5-strides8_8_4_context1_templates-15x3_11x3_7x3-noise10_trial%d';
    %resFile = 'testSweep01__probMap-cov_ds4_cell-dims7_7_5-strides8_8_4_context0_templates-15x3_11x3_7x3-noise10_trial%d';
    resFile = 'testSweep04__probMap-cov4x1_4x1_4x1_4x1__ds4_cell-dims7_7_5-strides8_8_4_context1_templates-15x3_11x3_7x3-noise10_trial%d';
    
    trialStart = 0;
    nTrials = 2;
    
    allAuc= zeros(nTrials,1);
    
    for (t=trialStart:trialStart+nTrials-1)
        file = [resFolder,sprintf(resFile,t)];
        display(['Analyzing: ', file]);
        
        load(file);
        
        y = cleanTestData(:);
        tp = zeros(numel(cleanTestData),numel(probOn));
        fp = zeros(numel(cleanTestData),numel(probOn));
        auc = zeros(numel(probOn),1);
        [rotTemplates,~] = getRotTemplates(params,templateStruct);
        
        for (i=1:numel(probOn))
            probPixel = viewAllParticles(allParticles{i},rotTemplates,params);
            [tp(:,i),fp(:,i),auc(i)] = getROC(probPixel(:),y);
        end
        
        allAuc(t-trialStart+1) = auc(end);
        
%         figure(88);
%         plot(fp(:,end),tp(:,end),'o-'); hold on; plot(0:0.1:1,0:0.1:1,'r');
%         xlabel('false positive');
%         ylabel('true positive');
%         title(['ROC curve at final iteration. AUC: ', num2str(auc(end))]);
% 
%         figure(90);
%         plot(1:numel(auc),auc,'o-');
%         xlabel('# active bricks');
%         ylabel('AUC of ROC');
%         title(['Average ROC curve']);
%         
%         display('done');
%         pause
    end
end

