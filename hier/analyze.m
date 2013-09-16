function allAuc = analyze()

    resFolder = 'resAlpha2/';
    resFile = 'testSweep0%d__probMap-cov4x1_4x1_4x1_4x1__ds4_cell-dims7_7_5-strides8_8_4_context1_alpha%d_templates-15x3_11x3_7x3-selfRoot100-noise10_trial%d';
    
    alphaTry = [400:100:1000];
    testInds =[1:5];
    
    trialStart = 0;
    nTrials = 3;
    
    allAuc= zeros(numel(testInds),numel(alphaTry),nTrials);
    
    for(ti=1:numel(testInds))
        for (at=1:numel(alphaTry))
            for (t=trialStart:trialStart+nTrials-1)
                file = [resFolder,sprintf(resFile,testInds(ti),alphaTry(at),t)];
                display(['Analyzing: ', file]);

                load(file,'cleanTestData','allParticles','probOn','params','templateStruct');
                imSize = size(cleanTestData);

                y = cleanTestData(:);
                tp = zeros(numel(cleanTestData),numel(probOn));
                fp = zeros(numel(cleanTestData),numel(probOn));
                auc = zeros(numel(probOn),1);
                [rotTemplates,~] = getRotTemplates(params,templateStruct);

                for (i=1:numel(probOn))
                    probPixel = viewAllParticles(allParticles{i},rotTemplates,params,imSize);
                    [tp(:,i),fp(:,i),auc(i)] = getROC(probPixel(:),y);
                end

                allAuc(ti,at,t-trialStart+1) = auc(end);
            end
        end
        
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

