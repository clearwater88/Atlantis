function allAuc = analyze()

    resFolder = 'resDataEx/';
    resFile = 'testSweep0%d_imSize%d-%d__probMap-cov4x1_4x1_4x1_4x1__ds1_cell-dims7_7_5-strides8_8_4_context%d_alpha10_templates-17x3_9x3_5x3-selfRoot-10-100-1000_noise%d_trial%d';
    
    imSizeTry = [50,75,100];
    contextTry = [0,1];
    noiseTry = [1:2:31];
    
    testInds =[6:10];
    
    trialStart = 0;
    nTrials = 2;
    
    allAuc= zeros(numel(noiseTry),numel(contextTry),numel(testInds),numel(imSizeTry),nTrials);
    for (imt=1:numel(imSizeTry))
        for (at=1:numel(contextTry))        
            for(ti=1:numel(testInds))
                for(nt=1:numel(noiseTry))
                    for (t=trialStart:trialStart+nTrials-1)
                        file = [resFolder,sprintf(resFile,testInds(ti),imSizeTry(imt),imSizeTry(imt),contextTry(at),noiseTry(nt),t)];
                        display(['Analyzing: ', file]);

                        load(file,'cleanTestData','allParticles','params','templateStruct');

                        imSize = size(cleanTestData);

                        y = cleanTestData(:);
 
                        [rotTemplates,~] = getRotTemplates(params,templateStruct);

                        probPixel = viewAllParticles(allParticles{end},rotTemplates,params,imSize);
                        [~,~,auc] = getROC(probPixel(:),y);
                        
%                         for (i=1:numel(allParticles))
%                             probPixel = viewAllParticles(allParticles{i},rotTemplates,params,imSize);
%                             [tp(:,i),fp(:,i),auc(i)] = getROC(probPixel(:),y);
%                         end

                        allAuc(nt,at,ti,imt,t-trialStart+1) = auc;
                    end
                end
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

