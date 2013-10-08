function viewGenData(nStart,nEnd,imSize,templateStrat)
    
    genDataFolder = 'genDataEx/';
    str = [genDataFolder,'ex%d_imSize%d-%d_noiseParam-%d','templateStrat-%d'];
    %str = [genDataFolder,'exClean%d_imSize%d-%d'];
    noiseTry = [1:3:49];
    
    ct=1;
    for(n=nStart:nEnd)

        ims = cell(numel(noiseTry),1);
%         sz(1)= ceil(sqrt(numel(noiseTry)));
%         sz(2) = ceil(numel(noiseTry)/sz(1));
        
        sz(1)= nEnd-nStart+1;
        sz(2) = numel(noiseTry);

        for(nt=1:numel(noiseTry))
            load(sprintf(str,n,imSize(1),imSize(2),noiseTry(nt),templateStrat),'data','probPixel');
            ims{nt} = data;
        
%             figure(1);
%             subplot(sz(1),sz(2),nt); imshow(data);    
%             title(['Noise parameter: ', num2str(noiseTry(nt)/100)]);


            figure(1);
            subplot(sz(1),sz(2),ct); imshow(data);    
            title([num2str(noiseTry(nt)/100)]);
            ct=ct+1;

        end
        figure(2);
        subplot(1,sz(1),n-nStart+1); imshow(probPixel);
%         
        
%         sz1 = ceil(sqrt(numel(noiseTry)));
%         sz2 = ceil(numel(noiseTry)/sz1);
%         
%         load(sprintf(str,n,imSize(1),imSize(2)),'cleanData');
%         ims{1} = cleanData;
%         sz1= 1; sz2= 1;
% 
%         figure(1);
%         imshow(makeCollage(ims,[sz1,sz2]));
    end
    
end

