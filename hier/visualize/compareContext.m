function compareContext(nStart,nEnd,nTrials,noise,imSize)
    
    resFolder = 'resDataEx/';

    
    str = [resFolder,'testSweep0%d_imSize%d-%d__probMap-cov4x1_4x1_4x1_4x1__ds1_cell-dims7_7_5-strides8_8_4_context%d_alpha10_templates-17x3_9x3_5x3-selfRoot-10-100-1000_noise%d_trial%d'];
    
    for (n=nStart:nEnd)
        
        probPixelNoContext = cell(nTrials,1);
        probPixelContext = cell(nTrials,1);
        
        aucContext = zeros(nTrials,1);
        aucNoContext = zeros(nTrials,1);
        
        for (t=0:nTrials-1)
            
            file = sprintf(str,n,imSize(1),imSize(2),1,noise,t);
            load(file,'cleanTestData','testData');
            probPixelContext{t+1} = viewAllParticlesFromFile(file);
            [~,~,auc] =  getROC(probPixelContext{t+1}(:),cleanTestData(:));
            aucContext(t+1) = auc;
            
            
            file = sprintf(str,n,imSize(1),imSize(2),0,noise,t);
            probPixelNoContext{t+1} = viewAllParticlesFromFile(file);
            [~,~,auc] =  getROC(probPixelNoContext{t+1}(:),cleanTestData(:));
            aucNoContext(t+1) = auc;
        end
        
        
        figure(1);
        for (i=1:numel(probPixelContext))
           subplot(numel(probPixelContext), 2,i); imshow(probPixelContext{i});
           title(['Context: ', num2str(aucContext(i))]);
        end
        
        for (i=1:numel(probPixelNoContext))
           subplot(numel(probPixelNoContext),2,i+numel(probPixelContext)); imshow(probPixelNoContext{i});
           title(['No context: ', num2str(aucNoContext(i))]);
        end
        
%         figure(1);
%         imshow(makeCollage(probPixelContext,[1,nTrials]));
%        
%         figure(2);
%         imshow(makeCollage(probPixelNoContext,[1,nTrials]));
        
%         temp = cat(1,probPixelContext,probPixelNoContext);

%         figure(100);
%         imshow(makeCollage(temp,[2,nTrials]));
%         
%         load(file,'cleanTestData','testData');
%         figure(101);
        
        figure(3);
        subplot(1,2,1); imshow(cleanTestData);
        subplot(1,2,2); imshow(testData);
        pause;
    end

    
end

