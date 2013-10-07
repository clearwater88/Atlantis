function allAuc = analyze()

    resFolder = 'resDataEx/';
    resFile = 'testSweep%d_imSize%d-%d__probMap-cov4x4_4x4_4x4_4x4_4x4_4x4_4x4_4x4_4x4__ds1_cell-dims5_5_5_5-strides3_3_3_3_context%d_alpha100_templates-33x5_17x5_9x5_5x5-selfRoot-0-0-0-1_noise%d_trial%d';
    
    imSizeTry = [75];
    contextTry = [1];
    noiseTry = [5:5:50];
    
    testInds =[1:5];
    
    trialStart = 0;
    nTrials = 1;
    
    allAuc= zeros(numel(noiseTry),numel(contextTry),numel(testInds),numel(imSizeTry),nTrials);
    for (imt=1:numel(imSizeTry))
        for (at=1:numel(contextTry))        
            for(ti=1:numel(testInds))
                for(nt=1:numel(noiseTry))
                    for (t=trialStart:trialStart+nTrials-1)
                        file = [resFolder,sprintf(resFile,testInds(ti),imSizeTry(imt),imSizeTry(imt),contextTry(at),noiseTry(nt),t)];
                        
                        if(~exist([file,'.mat'],'file'))
                            display(['Warning, file does not exist: ', file]);
                            continue;
                        end
                        
                        
                        display(['Analyzing: ', file]);

                        load(file,'cleanData','allParticles','params','templateStruct');

                        imSize = size(cleanData);

                        y = cleanData(:);
 
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

